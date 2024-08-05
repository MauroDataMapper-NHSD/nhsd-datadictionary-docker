@ECHO OFF

dot architecture.dot -Tpng -Gdpi=300 -o architecture.png
pandoc --from=markdown -V papersize=a4 -V geometry:margin=2cm -V geometry:top=1cm --pdf-engine=xelatex -o aws-deployment.pdf aws-deployment.md