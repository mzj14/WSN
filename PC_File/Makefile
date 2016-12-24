GEN=OscilloscopeMsg.java

all: oscilloscope.jar

oscilloscope.jar: Oscilloscope.class
	jar cf $@ *.class

OscilloscopeMsg.java: Oscilloscope.h
	mig -target=null -java-classname=OscilloscopeMsg java Oscilloscope.h oscilloscope -o $@

Oscilloscope.class: $(wildcard *.java) $(GEN)
	javac *.java

clean:
	rm -f *.class $(GEN)

veryclean: clean
	rm oscilloscope.jar
