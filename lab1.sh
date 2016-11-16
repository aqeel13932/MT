paste OpenSubtitles2016.en-et.{et,en} | shuf | head -10000 > mixed-data.both
sed -n 1,100p mixed-data.both | cut -f 1 > test.et
sed -n 1,100p mixed-data.both | cut -f 2 > test.en
sed -n 101,200p mixed-data.both | cut -f 1 > dev.et
sed -n 101,200p mixed-data.both | cut -f 2 > dev.en
sed -n 201,10000p mixed-data.both | cut -f 1 > train.et
sed -n 201,10000p mixed-data.both | cut -f 2 > train.en
for f in {test,dev,train}.{en,et};
do
	   /home/aqeel/MT/moses/scripts/tokenizer/tokenizer.perl < $f > tok-$f
done
/home/aqeel/MT/moses/scripts/recaser/train-truecaser.perl --model en-truecase.mdl --corpus tok-train.en
/home/aqeel/MT/moses/scripts/recaser/train-truecaser.perl --model et-truecase.mdl --corpus tok-train.et
for lang in {en,et};
do
	for f in {test,dev,train}.$lang;
	do
		/home/aqeel/MT/moses/scripts/recaser/truecase.perl --model $lang-truecase.mdl < tok-$f > tc-tok-$f
	done
done
/home/aqeel/MT/moses/scripts/training/clean-corpus-n.perl tokenized-and-lowecased en et cleaned 1 100
/home/aqeel/MT/moses/bin/lmplz -o 5 -S 50% < tc-tok-train.en > lm-en.arpa
/home/aqeel/MT/moses/scripts/training/train-model.perl --corpus tc-tok-train --f et --e en --external-bin-dir /home/aqeel/MT/moses/bin --lm 0:5:$(pwd)/lm-en.arpa --root-dir mt-experiment-1 --reordering msd-bidirectional-fe --mgiza --mgiza-cpus 2
/home/aqeel/MT/moses/scripts/training/mert-moses.pl tc-tok-dev.et tc-tok-dev.en /home/aqeel/MT/moses/bin/moses $(pwd)/mt-experiment-1/model/moses.ini  --working-dir  $(pwd)/mt-experiment-1/mert-1 --threads 4 --decoder-flags "--threads 4"
/home/aqeel/MT/moses/bin/moses -f mt-experiment-1/mert-1/moses.ini -i tc-tok-test.et > hypothesis0.en
/home/aqeel/MT/moses/scripts/generic/multi-bleu.perl tc-tok-test.en < hypothesis0.en > out.log
