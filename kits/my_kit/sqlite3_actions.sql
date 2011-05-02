CREATE TABLE clones (
	"bit" INTEGER NOT NULL,
	"status" TEXT NOT NULL DEFAULT ('pending'),
	"src" INTEGER NOT NULL
);
CREATE TABLE upgrades (
	"bit" INTEGER NOT NULL,
	"status" TEXT NOT NULL DEFAULT ('pending'),
	"component" TEXT NOT NULL,
	"file" TEXT NOT NULL
);
CREATE TABLE commits (
	"bit" INTEGER NOT NULL,
	"status" TEXT NOT NULL DEFAULT ('pending'),
	"commit" TEXT
);
