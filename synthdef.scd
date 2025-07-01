(
SynthDef(\gran_1a, {
	arg out = 0, bufNum = 0, posLo = 0.0, posHi = 1.0,
    posRate = 1, posDev = 0.01, trigRate = 100, granDur = 0.1, rate = 1.0,
    panMax = 1, amp = 0.1, interp = 4;

    var trig, pan, pos, bufDur, bufDurSection, posDif;

    posDif = posHi - posLo;
    bufDur = BufDur.kr(bufNum);
    bufDurSection = bufDur * posDif;
	trig = Impulse.kr(trigRate.lag(5));
    pos = posLo * bufDur +
	(Phasor.ar(0, BufRateScale.kr(bufNum) * posRate.lag(3) / SampleRate.ir, posLo * bufDur, posHi * bufDur) +
        (TRand.kr(-0.5 * posDev, 0.5 * posDev.lag(3), trig) * bufDur)).mod(bufDurSection);
	// pan = Demand.kr(trig, 0, Dseq([panMax, panMax.neg],inf) * 0.999);
	Out.ar(out, TGrains.ar(1, trig, bufNum, rate.lag(3), pos, granDur.lag(4), 0, 1, interp) * amp.lag(3));
    }, metadata: (
        specs: (
            posLo: [0.01, 0.99, \lin, 0.01, 0],
            posHi: [0.01, 0.99, \lin, 0.01, 1],
            posRate: [0.1, 2, \lin, 0.01, 1],
            posDev: [0, 0.2, 5, 0, 0.01],
            granDur: [0.01, 0.3, \lin, 0.01, 0.1],
            trigRate: [1, 200, \lin, 0.01, 100],
            rate: [0.1, 10, \lin, 0.01, 1],
            panMax: [0.0, 1, \lin, 0.005, 0.8],
            amp: [0.0, 0.5, \lin, 0.005, 0.25]
        )
    )
).add;

SynthDef(\fxchain, {
	arg pitch=1, delaywet=0, out=0, in=0, wet=0, sat=1;
	var sig, pan, delay;
	pan = 0; //en chantier
	sig = In.ar(in, 1);

	sig = PitchShift.ar(sig, 0.25, pitch.lag(1));
	sig = (sat * sig).tanh;
	sig = sig + CombC.ar(sig, 0.25, LFNoise2.ar(0.5).linlin(-1,1, 0.05, 0.2), 1, wet);

	// sig = Balance2.ar(sig, delay, wet);
	sig = Limiter.ar(sig, 0.987);
	sig = Pan2.ar(sig, pan);

	Out.ar(out,sig);
}).add;

SynthDef(\comb_saturation, {
	arg in, out=0, drywet=0;
	var sig, dry;

	dry = In.ar(in,2);
	sig = BPF.ar(dry, (0..20).normalize.linlin(0,1,40,5000), 0.1).sum * 10.dbamp;
	sig = sig.fold2;
	sig = Balance2.ar(dry, sig, drywet);

	Out.ar(out, sig);
}).add;


SynthDef(\reverb, {
	arg in, out=0, drywet=0, time=0.5;
	var sig, dry;

	dry = In.ar(in,2);
	sig = MiVerb.ar(dry,0.4, drywet.lag(3), 0.3, 0.1);
	Out.ar(out, sig);
}).add;

SynthDef(\voiceBus, {
	arg in, out=0, amp=0.5;
	var sig, dry;

	sig = In.ar(in,1) * amp.lag(3);
	Out.ar(out, sig);
}).add;
)