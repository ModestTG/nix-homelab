set quiet

default:
  @just --list

rebuild-pre:
  git add .

apply: rebuild-pre
  colmena apply

build: rebuild-pre
  colmena build
