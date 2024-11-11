TITLE = catalyst2024slides

all: slides clean

slides:
	xelatex $(TITLE)
	xelatex $(TITLE)

clean:
	rm -f $(addprefix $(TITLE), .aux .log .nav .out .snm .toc .vrb .bbl .blg)
