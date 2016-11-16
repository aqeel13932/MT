#wget http://statmt.org/europarl/v7/et-en.tgz
#tar zxvf et-en.tgz
MOSES=/home/aqeel/MT/moses
#$MOSES/scripts/tokenizer/tokenizer.perl < europarl-v7.et-en.en > tok.en
#$MOSES/scripts/tokenizer/tokenizer.perl < europarl-v7.et-en.et > tok.et
#$MOSES/scripts/tokenizer/lowercase.perl < tok.et > tok-lc.et
#$MOSES/scripts/tokenizer/lowercase.perl < tok.en > tok-lc.en
#$MOSES/scripts/training/clean-corpus-n.perl tok-lc et en clean 1 99
#paste clean.{et,en} | shuf > shuf.both
#sed -n 1,10000p shuf.both | cut -f 1 > train.et
#sed -n 1,10000p shuf.both | cut -f 2 > train.en
#sed -n 10001,10100p shuf.both | cut -f 1 > dev.et
#sed -n 10001,10100p shuf.both | cut -f 2 > dev.en
#sed -n 10101,10200p shuf.both | cut -f 1 > test.et
#sed -n 10101,10200p shuf.both | cut -f 2 > test.en
