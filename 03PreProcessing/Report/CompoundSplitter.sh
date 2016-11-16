MOSES=/home/aqeel/MT/moses
echo Preparing Data
tst=2000
trn=1000000
dev=5000
all=0
let "all=tst+trn+dev"

echo Tokinize the all data
$MOSES/scripts/tokenizer/tokenizer.perl -threads 8 < OpenSubtitles2016.ar-en.ar > tok-OpenSubtitles2016.ar-en.ar
echo Take $trn for training , $dev for dev , $tst for testing
sed -n 1,"$all"p tok-OpenSubtitles2016.ar-en.ar > all.ar.org
sed -n 1,"$all"p OpenSubtitles2016.ar-en.en > all.en
echo Train the compound spiltter on all the dataset
$MOSES/scripts/generic/compound-splitter.perl -train -corpus tok-OpenSubtitles2016.ar-en.ar -model csmodel #-min-size 5
echo generate the cs data
$MOSES/scripts/generic/compound-splitter.perl -model csmodel < all.ar.org > all.ar

echo Split the data
lstart=0
lend=0
let "stlimit+=1"
let "lend=trn"
sed -n "$stlimit","$lend"p all.ar > train.ar
sed -n "$stlimit","$lend"p all.en > train.en
let "stlimit+=trn"
let "lend=stlimit+dev"
sed -n "$stlimit","$lend"p all.ar > dev.ar
sed -n "$stlimit","$lend"p all.en > dev.en

let "stlimit+=dev"
let "lend = stlimit+tst"
sed -n "$stlimit","$lend"p  all.ar > test.ar
sed -n "$stlimit","$lend"p all.en > test.en
rm all.ar all.en
echo Tokinizing Data
for f in {train,dev,test}.{en,};
do
	$MOSES/scripts/tokenizer/tokenizer.perl -threads 8 < $f > tok-$f
	rm $f
done
echo Truecasing English
$MOSES/scripts/recaser/train-truecaser.perl --model en-truecase.mdl --corpus tok-train.en
for f in {test,dev,train}.en;
do
	$MOSES/scripts/recaser/truecase.perl --model en-truecase.mdl < tok-$f > tc-tok-$f
	rm tok-$f
done
for f in {train,dev,test};
do
	mv $f.ar tc-tok-$f.ar
	rm $f.ar
done

$MOSES/+scripts/training/clean-corpus-n.perl tokenized-and-lowecased ar en cleaned 1 100

$MOSES/bin/lmplz -o 5 -S 50% < tc-tok-train.en > lm-en.arpa
$MOSES/bin/build_binary lm-en.arpa lm-en.blm

$MOSES/scripts/training/train-model.perl --corpus tc-tok-train --f ar --e en --external-bin-dir $MOSES/bin --lm 0:5:$(pwd)/lm-en.blm --root-dir mt-experiment-1 --reordering msd-bidirectional-fe --mgiza --mgiza-cpus 8
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
	$MOSES/scripts/training/mert-moses.pl $(pwd)/tc-tok-dev.ar $(pwd)/tc-tok-dev.en $MOSES/bin/moses $(pwd)/mt-experiment-1/model/moses.ini  --working-dir  $(pwd)/mt-experiment-1/mert-$i --threads 4 --decoder-flags "--threads 4" > mert-$i.out
done
#Change the direction toe the new phrase table before continue
:<<'END'
for i in `seq 1 3`;
do	
	$MOSES/bin/moses -f mt-experiment-1/mert-$i/moses.ini -i tc-tok-test.ar > mt-experiment-1/mert-$i/hypothesis0.ar
	$MOSES/scripts/generic/multi-bleu.perl tc-tok-test.en < mt-experiment-1/mert-$i/hypothesis0.ar > out_$i.txt
done
END
