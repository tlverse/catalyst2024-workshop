TITLE = catalyst2024slides

all: $(TITLE).pdf clean

$(TITLE).pdf:
	xelatex $(TITLE)
	xelatex $(TITLE)

clean:
	rm -f $(addprefix $(TITLE), .aux .log .nav .out .snm .toc .vrb .bbl .blg)
