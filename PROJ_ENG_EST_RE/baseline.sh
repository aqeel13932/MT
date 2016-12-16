MOSES=/home/aqeel/MT/moses

echo Preparing Data
tst=10000
trn=5000000
dev=5000
all=0
let "all=tst+trn+dev"

:<<'END'
echo Take $trn for training , $dev for dev , $tst for testing
sed -n 1,"$all"p OpenSubtitles2016.en-et.et > all.et
sed -n 1,"$all"p OpenSubtitles2016.en-et.en > all.en

echo Tokinizing Data
for f in all.{et,en};
do
	$MOSES/scripts/tokenizer/tokenizer.perl -threads 8 < $f > tok-$f
	rm $f
done
echo Truecasing English
$MOSES/scripts/recaser/train-truecaser.perl --model en-truecase.mdl --corpus tok-all.en
$MOSES/scripts/recaser/truecase.perl --model en-truecase.mdl < tok-all.en > tc-tok-all.en
rm tok-all.en

echo Truecasing Estonian
$MOSES/scripts/recaser/train-truecaser.perl --model et-truecase.mdl --corpus tok-all.et
$MOSES/scripts/recaser/truecase.perl --model et-truecase.mdl < tok-all.et > tc-tok-all.et
rm tok-all.et
echo Concating Source and destination languages.
python3 concate.py
echo Doing Fast Align to generate the allignments.
END
:<<'END'
echo Split the data
lstart=0
lend=0
let "stlimit+=1"
let "lend=trn"
sed -n "$stlimit","$lend"p tc-tok-all.et > tc-tok-train.et
sed -n "$stlimit","$lend"p re-tc-tok-all.en > tc-tok-train.en
let "stlimit+=trn"
let "lend=stlimit+dev"
sed -n "$stlimit","$lend"p tc-tok-all.et > tc-tok-dev.et
sed -n "$stlimit","$lend"p re-tc-tok-all.en > tc-tok-dev.en

let "stlimit+=dev"
let "lend = stlimit+tst"
sed -n "$stlimit","$lend"p  tc-tok-all.et > tc-tok-test.et
sed -n "$stlimit","$lend"p re-tc-tok-all.en > tc-tok-test.en
#rm all.et

$MOSES/+scripts/training/clean-corpus-n.perl tokenized-and-lowecased et en cleaned 1 100

$MOSES/bin/lmplz -o 5 -S 50% < tc-tok-train.et > lm-et.arpa
$MOSES/bin/build_binary lm-et.arpa lm-et.blm

$MOSES/scripts/training/train-model.perl --corpus tc-tok-train --f en --e et --external-bin-dir $MOSES/bin --lm 0:5:$(pwd)/lm-et.blm --root-dir mt-experiment-1 --reordering msd-bidirectional-fe --mgiza --mgiza-cpus 8
# To Enhance Peroframce Later (on Testing level).
cd mt-experiment-1
mkdir binarised-model
$MOSES/bin/processPhraseTableMin -in model/phrase-table.gz -nscores 4 -out binarised-model/phrase-table
$MOSES/bin/processLexicalTableMin -in model/reordering-table.wbe-msd-bidirectional-fe.gz -out binarised-model/reordering-table
cd ..



for i in `seq 1 3`;
do	
	echo ====================$i=====================
#	$MOSES/scripts/training/mert-moses.pl $(pwd)/tc-tok-dev.ar $(pwd)/tc-tok-dev.en $MOSES/bin/moses train/model/moses.ini --mertdir $MOSES/bin/ --decoder-flags="-threads all" &> mert$i.out 
	$MOSES/scripts/training/mert-moses.pl $(pwd)/tc-tok-dev.et $(pwd)/tc-tok-dev.en $MOSES/bin/moses $(pwd)/mt-experiment-1/model/moses.ini  --working-dir  $(pwd)/mt-experiment-1/mert-$i --threads 4 --decoder-flags "--threads 4" > mert-$i.out
done
END

#:<<'END'
for i in `seq 1 3`;
do

	$MOSES/bin/moses -f mt-experiment-1/mert-$i/moses.ini -i tc-tok-test.en > mt-experiment-1/mert-$i/hypothesis0.et
	$MOSES/scripts/generic/multi-bleu.perl tc-tok-test.et < mt-experiment-1/mert-$i/hypothesis0.et > out_$i.txt
done
#END


