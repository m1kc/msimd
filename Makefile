all:
	dmd -w -wi -O -of'main' -unittest main.d packet.d storage.d # -I/usr/share/vibed/source # vibe/*.d vibe/*/*.d vibe/*/*/*.d deimos/*.d deimos/*/*.d # -cov
