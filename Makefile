all:
	dmd -w -wi -O -of'main' main.d packet.d storage.d  # -unittest -cov
