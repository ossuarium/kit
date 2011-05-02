CREATE TABLE "permissions" (
	"name" INTEGER NOT NULL,
	"bit" INTEGER NOT NULL
);
CREATE TABLE projects (
	"name" TEXT NOT NULL,
	"git" TEXT NOT NULL
);
CREATE TABLE bits (
	"name" TEXT NOT NULL,
	"project" INTEGER NOT NULL,
	"root" TEXT NOT NULL,
	"commit" TEXT,
	"commit_time" INTEGER
);