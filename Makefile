all:
	dmd -w -wi -O -of'main' -I. -unittest *.d # -cov
