#####################

#SOURCES_BASE = types.nim reader.nim printer.nim
#SOURCES_LISP = env.nim core.nim stepA_mal.nim
#SOURCES = $(SOURCES_BASE) $(SOURCES_LISP)
#SOURCES_REBUILD = $(SOURCES_BASE) env.nim core.nim

#####################

#SRCS = step0_repl.nim step1_read_print.nim step2_eval.nim step3_env.nim \
	step4_if_fn_do.nim step5_tco.nim step6_file.nim step7_quote.nim \
	step8_macros.nim step9_try.nim stepA_mal.nim
SRCS = step0_repl.nim
BINS = $(SRCS:%.nim=%)

#####################

all: $(BINS) mal

mal: $(word $(words $(BINS)),$(BINS))
	cp $< $@

$(BINS): %: %.nim $(SRCS)
	nim -d:release --nimcache:nimcache-$@ c $@

clean:
	rm -rf nimcache-*/ $(BINS)
	rm -f mal
