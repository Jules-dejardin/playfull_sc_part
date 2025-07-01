(
// Load factory
"loadBuffers.scd".loadRelative;
"busses.scd".loadRelative;
"nodes.scd".loadRelative;
// "events.scd".loadRelative;
// "server.scd".loadRelative;
~gran = Array.fill(3, {()});

~projectPath=PathName(thisProcess.nowExecutingPath).parentPath;
~sampleDirPath=~projectPath++"samples/";

// 4 register functions
ServerBoot.add(~loadSamples); // fill up the ~buffers dict
ServerBoot.add(~makeBusses);
// ServerQuit.add(~cleanup);

// 5 boot serv
s.waitForBoot({
	s.sync;
	"synthdef.scd".loadRelative;
	ServerTree.add(~makeNodes);
	// ServerTree.add(~makeEvents);
	s.freeAll;

	s.sync;
	"done".postln;
});
)






(
~buffer_1 = Buffer.read(s,"/home/jules/Documents/SuperTuning_all/27_avril_quadriiiii/samples/puit/quatre_impulse.wav");
~buffer_2 = Buffer.read(s,"/home/jules/Documents/SuperTuning_all/27_avril_quadriiiii/samples/nylonbox/mono_nylonbox_pig_to_tens_2.wav");
~buffer_3 = Buffer.read(s,"/home/jules/Documents/SuperTuning_all/27_avril_quadriiiii/samples/grenouilles/tutulu.wav");
~fxbus = Bus.audio(s,1);
~revbus = Bus.audio(s,1);
)
~buffer_1 = Buffer.read(s,"/home/jules/Musique/pervers_tondelier.wav");
~buffer_1 = Buffer.read(s,"/home/jules/.local/share/nicotine/downloads/day.mp3");

(
~gran = Array.fill(3, {()});
~gran[0] = Synth(\gran_1a, [\bufNum, ~buffer_1.bufnum,\out, ~fxbus, \amp,0.8]);
~gran[1] = Synth(\gran_1a, [\bufNum, ~buffer_2.bufnum,\out, ~fxbus, \amp,0.8]);
~gran[2] = Synth(\gran_1a, [\bufNum, ~buffer_3.bufnum,\out, ~fxbus, \amp,0.8]);
~fx = Synth(\fxchain, [\in, ~fxbus, \out, ~revbus], addAction:'addToTail');
~rev = Synth(\reverb, [\in, ~revbus, \out, 0], addAction:'addToTail');
)