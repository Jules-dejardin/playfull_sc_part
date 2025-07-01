(
~makeNodes = {

	s.bind({
		~mainGrp = Group.new;
		~granGrp = Group.after(~mainGrp);
		~fxGrp = Group.after(~granGrp);
		~reverbGrp = Group.after(~fxGrp);

		~voices = Synth.new(\voiceBus,
			[
				\in, ~bus[\granBus],
				\out, ~bus[\fxBus],
				\amp, 0.5
			],
			~granGrp
		);
		// ~fx.set(\pitch, 3)
		~fx = Synth.new(
			\fxchain,
			[
				\in, ~bus[\fxBus],
				\out,~bus[\reverbBus],
			],
			~fxGrp
		);

	~reverb = Synth.new(
			\reverb,
			[
				\in, ~bus[\reverbBus],
				\out, 0,
			],
			~reverbGrp
		);

	});
};
)

