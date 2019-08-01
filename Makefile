.PHONY: all paper help html publish watch clean cp-figs

SHELL := /bin/bash
PAPERDIR=paper
MATLABDIR=matlab
TIKZDIR=tikz

PAPERNAME=paper

all: paper html publish

paper: cp-figs tangle tex pdf clean

help:
	@echo "Usage: make <command>"
	@echo "  all     - Cp-figs tex pdf html publish"
	@echo "  paper   - Compile the org file to a pdf"
	@echo "  html    - Export all the org files to html"
	@echo "  publish - Commit everything and push to repository"
	@echo "  tex     - Export to paper in org format to tex"
	@echo "  tangle  - Tangle everything that is in the org paper and tikz file"
	@echo "  pdf     - Compile the tex file to pdf"
	@echo "  watch   - Watch the tex file for changes and compile"
	@echo "  clean   - Clean the paper directory"
	@echo "  cp-figs - Copy all the necessary figures from tikz and matlab folder to paper folder"

html:
	for f in *.org;              do emacsclient -e "(progn (find-file \"$$f\") (org-html-export-to-html))"; done
	for f in $(TIKZDIR)/*.org;    do emacsclient -e "(progn (find-file \"$$f\") (org-html-export-to-html))"; done
	for f in $(MATLABDIR)/*.org; do emacsclient -e "(progn (find-file \"$$f\") (org-html-export-to-html))"; done

publish:
	git add . && git commit -m "Update - $$(date +%F)" && git push origin master

tex: $(PAPERDIR)/$(PAPERNAME).org
	emacsclient -e '(progn (find-file "$(PAPERDIR)/$(PAPERNAME).org") (org-latex-export-to-latex))'

tangle: $(PAPERDIR)/$(PAPERNAME).org
	emacsclient -e '(progn (find-file "$(PAPERDIR)/$(PAPERNAME).org") (org-babel-tangle))'
	emacsclient -e '(progn (find-file "$(TIKZDIR)/index.org") (org-babel-tangle))'

pdf: $(PAPERDIR)/$(PAPERNAME).tex
	latexmk -cd -quiet -bibtex $(PREVIEW_CONTINUOUSLY) -f -pdf -pdflatex="xelatex -synctex=1 -interaction nonstopmode" -use-make $(PAPERDIR)/$(PAPERNAME).tex

# Set the PREVIEW_CONTINUOUSLY variable to -pvc to switch latexmk into the preview continuously mode
watch: PREVIEW_CONTINUOUSLY=-pvc
watch: pdf

watch-org: $(PAPERDIR)/$(PAPERNAME).org
	echo $(PAPERDIR)/$(PAPERNAME).org | entr -s 'make tangle tex pdf'

clean:
	latexmk -cd -c -bibtex $(PAPERDIR)/$(PAPERNAME).tex

cp-figs:
	bash scripts/cp-figs.sh
