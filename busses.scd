(

~makeBusses = {

	~bus = Dictionary.new;
	~bus.add(\granBus -> Bus.audio(s, 2));
	~bus.add(\fxBus -> Bus.audio(s, 2));
	~bus.add(\reverbBus -> Bus.audio(s, 2));
};

)
