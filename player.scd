// create the OSCFunc
~gran[0].set(\bufNum, ~buffer_1.bufnum);
~gran[1].set(\amp, 1);
~fx.set(\pitch, 5);
~fx.set(\delaywet, 0);

(
~gran[0] = Synth(\gran_1a, [\bufNum, ~buffers[\parle][0].bufnum,\out, ~bus[\granBus], \amp,0.8], ~mainGrp);
~gran[1] = Synth(\gran_1a, [\bufNum, ~buffers[\synth][3].bufnum,\out, ~bus[\granBus], \amp,0.8], ~mainGrp);
~gran[2] = Synth(\gran_1a, [\bufNum, ~buffers[\perc][2].bufnum,\out, ~bus[\granBus], \amp,0.8], ~mainGrp);
)

(
~voice = OSCFunc({
	arg msg;
	// [msg[0]].postln;
	case
	{msg[2] == 'amp'} {~gran[msg[1]].set(\amp,msg[3]); } // actif ou non
	{msg[2] == 'fx1'} {~fx.set(\pitch,msg[3].linlin(0,1,0,2)); } // Y
	{msg[2] == 'fx2'} {~fx.set(\delaywet,msg[3].linlin(0.5,1,-1, 0)); } // X
	{msg[2] == 'triggerRight'} {~rev.set(\drywet,msg[3].linlin(0,1,0,0.7)); } // gachette gauche
	{msg[2] == 'triggerLeft'} {~fx.set(\sat,msg[3].linlin(0,1,1,5)); } // gachette gauche
	{msg[2] == 'joystick0y'} {~gran[msg[1]].set(\granDur,msg[3].linexp(0,1,0.01,0.3)); } // Y curseur 1
	{msg[2] == 'joystick0y'} {~gran[msg[1]].set(\trigRate,msg[3].linexp(0,1,3,150)); } // Y curseur 1
	{msg[2] == 'joystick0x'} {~gran[msg[1]].set(\rate, msg[3].linexp(0,1,0.2,10));} //X curseur 1
	{msg[2] == 'joystick0x'} {~gran[msg[1]].set(\posDev, msg[3].linlin(0,1,-0.5,0.5));} //X curseur 1
	// {msg[1]==0 && msg[2] == 'trig'}{msg[3].postln}
	//ma fonction
},'/voice';
);
)
~voice.free;














(
SynthDef(\gran_1a, { arg out = 0, bufNum = 0, posLo = 0.0, posHi = 1.0,
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
	arg pitch=1, delaywet=0, out=0, in=0, wet=(-1);
	var sig, pan, delay;
	pan = 0; //en chantier
	sig = In.ar(in, 1);

	sig = PitchShift.ar(sig, 0.25, pitch.lag(1));
	delay = CombC.ar(sig, 0.25, LFNoise2.ar(0.5).linlin(-1,1, 0.05, 0.2), 1);

	sig = Balance2.ar(sig, delay, wet);
	sig = Limiter.ar(sig, 0.987);
	sig = Pan2.ar(sig, pan);
	Out.ar(out,sig);
}).add;

SynthDef(\reverb, {
	arg in, out=0, drywet=0, time=0.5;
	var sig, dry;

	dry = In.ar(in,1);
	sig = FreeVerb.ar(dry, drywet, 0.7, 0.5);
	sig = Pan2.ar(sig);
	Out.ar(out, sig);
}).add;
)

// b = Buffer.read(s, Platform.miSCellaneousDirs[0] +/+ "Sounds" +/+ "kitchen_sounds_1.wav");
// b = Buffer.read(s, Platform.miSCellaneousDirs[0] +/+ "Sounds" +/+ "kitchen_sounds_1.wav");
~synth = Synth(\gran_1a, [\bufNum, b.bufnum]);


~synth.set(\rate, 10)


~player = Synth(\player, [\buf, ~buffer_1, \trig, 1]);

(Routine{
~player.set(\trig_pitch, 1);
	0.1.wait;
~player.set(\trig_pitch, 0);
}.play;
)
~player.set(\trig_end, 1);
~player.set(\rate, 0.9);
~player.set(\amp, 5)
~player.set(\buf, ~buffer_3);
~player.set(\buf, ~buffer_1);




~player = Synth(\player, [\buf, ~buffer_1]);

(
SynthDef(\player, {
	arg rate=1, amp=(-5), out=0, buf, trig=0, trig_end=0, pan=0, pos=0.0, trig_pitch=0;
	var sig, env, end, pitch;
	pitch = EnvGen.kr(Env([0,1, 0], [0.01, 2], -4), trig_pitch).linlin(0,1,1,5);
	// pitch = Env.perc(0.01, 2).kr(trigger:trig_pitch).linlin(0,1,1,50);
	env = EnvGen.kr(Env([0,1], 0.1, -4), trig);
	end = EnvGen.kr(Env([1,0], 1, -4), trig_end, doneAction:2);
	sig = PlayBuf.ar(1, buf, rate.lag(0.03) * pitch,startPos:pos, loop:1);

	sig = sig * end * env * amp.dbamp;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
(
f = { |msg, time, addr|
    if(msg[0] != '/status.reply') {
        "time: % sender: %\nmessage: %\n".postf(time, addr, msg);
    }
};
thisProcess.addOSCRecvFunc(f);
);

// stop posting.
thisProcess.removeOSCRecvFunc(f);


(
~voice = 1;
~param = "posRate"
)
(
/* adresse IP du programme oF – n’importe quel port source */
~ofAddr = NetAddr("127.0.0.1", nil);

/* un tableau qui contiendra pour chaque voice un Environment
   (clé → valeur) qu’on mettra à jour à la volée                */
~state  = Array.fill(3, { () });        // 3 = NUMBER_OF_VOICES

/* handler universel */
OSCdef(\fromOF, { |msg, time, addr|
    // on ignore les messages venant d’ailleurs
msg.postln
    // EXEMPLE : mise à jour immédiate d’un Synth existant
    // ~voices[v].set(param, value);

}, "/voice" ++ "/"++~voice ++ "/"++ ~param, ~ofAddr, 57120).path;   // pathPattern=nil → on reçoit tout
)
