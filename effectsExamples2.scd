//Digital Audio Effects - Part 2

//load up some samples
b = SoundFile.collectIntoBuffers(Document.current.dir ++ "/samples/*");

//FEEDBACK
//https://www.musicradar.com/tuition/tech/distortion-saturation-and-bitcrushing-explained-549516
//https://www.theguardian.com/music/2008/nov/10/squarepusher-paul-hegarty-noise noise article + Merzbow video
//https://www.youtube.com/watch?v=T8p1lo6OziY&list=RDEM8Py22WnWlcLtVj8uTf7w4g&index=2 pansonic

//Install FbNode Quark
Quarks.install("Feedback");
(
SynthDef( \fb_buf, {
	arg bufnum, fbamt=0.85;
	var source = PlayBuf.ar( 2, bufnum );
	// read the feedback bus and delay the result.
	// The delay time defaults to the max delay time, 0.1 in this case.
	//This is hard coded and is not accessable to args though several FbNodes
	//can be created for a multi-tap effect
	var fbNode = FbNode( 2, 0.1 );
	var sig = fbNode.delay;
	// Add the input to the feedback signal, then filter and distort it.
	// for fun effects, try changing the fbamt to something greater than one
	sig = BPF.ar( sig*fbamt + source, 2000, 3.8).distort;
	// write the signal to the feedback buffer
	fbNode.write(sig);
	Out.ar( 0, sig );
}).add;

SynthDef( \fb_live, {
	arg bufnum, fbamt=0.85;
	var source = SoundIn.ar(0);
	var fbNode = FbNode( 1, 0.01 );
	var sig = fbNode.delay;
	sig = BPF.ar( sig*fbamt + source, 2000, 3.8).distort;
	fbNode.write(sig);
	//stereoize with Hass
	Out.ar( 0, [ sig, DelayC.ar(sig, 0.2, 0.025) ] );
}).add;
)

a = Synth( \fb_buf, [ \bufnum, b[5] ] );
a.set(\fbamt, 1.41);
a.free;

c = Synth( \fb_live );
c.set(\fbamt, 1.41);
c.free;

//Tape Delay via Greyhole
//https://reverb.com/news/repeat-that-a-brief-history-of-tape-echo
//https://nmbx.newmusicusa.org/delays-as-music/
//https://youtu.be/DMCTxkFwLHw?t=149 oliveros

//live in use headphones
{ Greyhole.ar( SoundIn.ar(), delayTime:0.25, damp:0, size:1, diff:0.707, feedback:0.9 )}.play;
{ Greyhole.ar( PlayBuf.ar(2, b[10], loop:1) , delayTime:0.3, damp:0, size:0.5, diff:0.4, feedback:1.1 ) }.play;

//Bit/Sample Crushing
//https://www.youtube.com/watch?v=sGXJMrvMGUM autechre
//https://www.youtube.com/watch?v=U0u-OB7ztMg&list=PLQaM7XrGgWVV4Dk9ykx8vRtudw4qaOWHe  ATR
//live in use headphones
{ Decimator.ar( SoundIn.ar(), rate:15000, bits:6 )}.play;
{ Decimator.ar( PlayBuf.ar(2, b[9], loop:1), rate:5000, bits:8 )}.play;

//Chip Tunes
//https://pulseradio.net/articles/2015/03/an-idiots-introduction-to-8-bit-music
//https://www.vice.com/en_us/article/8gdb7p/chipzels-complete-history-of-chiptune-939
//https://www.makeuseof.com/tag/making-8bit-music-hardware-native-trackers-chiptune-creation/
//http://songexploder.net/anamanaguchi  start @ 1:00
//https://www.youtube.com/watch?v=aTBSQKh8teE

(
SynthDef(\chippy_1, {
	arg pitch = 60, t_tr=1, dur=0.25,amp=1;
	var freq, sig, env, h1, h2;
	freq = pitch.midicps;
	h1 = TIRand.kr(2, 7, Impulse.kr(4));
	h2 = TIRand.kr(2, 7, Impulse.kr(4));
	env = EnvGen.ar( Env.perc(0.01, dur), t_tr, doneAction:2 );
	sig = AY.ar( AY.freqtotone(freq), AY.freqtotone(freq*h1), AY.freqtotone(freq*h2), 0.25,3,15,10,7);
	Out.ar(0, sig*env*amp);
}).add;
)

(
~bpm = 200;
~freq = ~bpm/60.0;
~tc = TempoClock(~freq);
 Pbind(
  \instrument, \chippy_1,
	\pitch,  Pseq([60, 55, \r, 52, \r, 57, 59, \r, 58, 57, 55, 64, 67, 69, 65, 67, \r, 64, 60, 62, 59], inf),
  \dur,  Pseq ([0.75, 0.5, 1, 1, 0.5, 1, 0.5, 0.5, 0.5, 1, 0.667, 0.667, 0.667, 1, 0.5, 0.5, 0.5, 1, 0.5, 0.5, 0.75], inf),
  \amp,  Pseq ([1,1,0, 1,0,1,1,0,1,1,1,1,1,1,1,1,0,1,1,1,1], inf)

).play(~tc)
)

// Fredrik Olofsson emulators
//https://github.com/redFrik/f0plugins
{Astrocade.ar}.play
{Astrocade.ar(1)}.play
{Astrocade.ar(2)}.play
{Astrocade.ar(2, 50)}.play
//--all three tones
{Astrocade.ar(0, MouseX.kr(0, 255), 100, 200, reg5:2r00001111, reg6:2r111111)}.play
//--noise only
{Astrocade.ar(reg5:2r00100000, reg6:0, reg7:255)}.play
{Pan2.ar(Astrocade.ar(LFSaw.kr(1, 0, 10, 10), 25, reg4:MouseX.kr(0, 255), reg5:MouseY.kr(0, 15)))}.play
{Pan2.ar(Astrocade.ar(SinOsc.kr(4, 0, 10, 10), SinOsc.kr(0.1, 0, 5, 20), reg4:MouseX.kr(0, 255), reg5:2r00010000, reg6:2r00001111, reg7:MouseY.kr(0, 15)))}.play
{Pan2.ar(Astrocade.ar(100, 255, reg4:2r00000111, reg5:MouseX.kr(0, 255), reg6:2r00001111, reg7:MouseY.kr(0, 255)))}.play
{Mix(Astrocade.ar(MouseX.kr(0, 255), LFPulse.kr((0.1..5)*30), LFPulse.kr((0.1..5)*40), LFPulse.kr((0.1..5)*50), reg5: 2r00000111, reg6:2r01110111).dup)}.play

{Atari2600.ar}.play

{Atari2600.ar(2, 3, 10, 10, 5, 5)}.play
{Atari2600.ar(MouseX.kr(0, 15), MouseY.kr(0, 15), 10, 10, 5, 5)}.play
{Atari2600.ar(2, 3, MouseX.kr(0, 31), MouseY.kr(0, 31), 5, 5)}.play
{Atari2600.ar(2, 3, 10, 10, MouseX.kr(0, 15), MouseY.kr(0, 15))}.play

{Atari2600.ar(MouseX.kr(0, 15), SinOsc.kr(0.35, 0, 7.5, 7.5), 10, MouseY.kr(0, 31), SinOsc.kr(0.3, 0, 5.5, 5.5), 5).dup}.play


(
SynthDef(\atari2600, {|out= 0, gate= 1, tone0= 5, tone1= 8, freq0= 10, freq1= 20, rate= 1, amp= 1, pan= 0|
	var e, z;
	e= EnvGen.kr(Env.asr(0.01, amp, 0.05), gate, doneAction:2);
	z= Atari2600.ar(tone0, tone1, freq0, freq1, 15, 15, rate);
	Out.ar(out, Pan2.ar(z*e, pan));
}).add;
)

(
Pbind(
	\instrument, \atari2600,
	\dur, 0.125,
	\amp, 0.8,
	\tone0, Pseq([Pn(3, 64), Pn(2, 128), Pn(10, 8)], inf),
	\tone1, Pseq([Pn(8, 32), Pwhite(0, 15, 12)], inf),
	\freq0, Pseq([Pn(10, 17), Pn(Prand([1, 2, 3]), 4), Pn(10, 3)], inf),
	\freq1, Pseq([10, 3, Pwrand([20, 1], [0.6, 0.4])], inf)
).play
)

(
Pbind(
	\instrument, \atari2600,
	\dur, Pbrown(0.1, 0.15, 0.1),
	\amp, 0.8,
	\tone0, 1,
	\tone1, 2,
	\freq0, Pseq([24, 24, Pwrand([20, 23], [0.6, 0.4])], inf),
	\freq1, Pseq([1, 3, Pwrand([2, 1], [0.6, 0.4])], inf)
).play
)

(
Pbind(
	\instrument, \atari2600,
	\dur, Pseq([0.06, 0.04], inf),
	\amp, 0.8,
	\tone0, Pseq([10, 10, 10, 3], inf),
	\tone1, Pseq([3, 3, 3, 3, 10], inf),
	\freq0, Pseq([1, 2, 3], inf),
	\freq1, Pseq([10, 2, 13, 5], inf)
).play
)

(
Pbind(
	\instrument, \atari2600,
	\dur, Pseq([0.25, 0.25, 0.25, 0.45], inf),
	\amp, 0.8,
	\tone0, Pseq([Pseq([2, 5], 32), Pseq([3, 5], 32)], inf),
	\tone1, 14,
	\freq0, Pseq([Pbrown(28, 31, 1, 32), Pbrown(23, 26, 3, 32)], inf),
	\freq1, Pseq([Pn(10, 16), Pn(11, 16)], inf)
).play
)

(
Pbind(
	\instrument, \atari2600,
	\dur, 0.1,
	\amp, 0.8,
	\tone0, Pseq([Pseq([10, 2], 32), Pseq([1, 9], 32), Pseq([1, 2, 4], 36)], inf),
	\tone1, Pseq([Pseries(10, 14, 16), Pseries(10, 5, 16)], inf),
	\freq0, Pseq([Pseries(10, 31, 16), Pseries(27, 31, 16)], inf),
	\freq1, Pseq([Pseries(9, 31, 16), Pseries(26, 31, 16)], inf)
).play
)

(
Pbind(
	\instrument, \atari2600,
	\dur, 0.1,
	\amp, 0.8,
	\legato, 1.5,
	\tone0, 15,
	\tone1, Pseq([Pn(2, 80), Pn(3, 80), Pn(4, 80), Pn(0, 40)], inf),
	\freq0, Pseq([Pseries(5, 0.1, 40)], inf),
	\freq1, Pseq([Pseries(10, 0.05, 50)], inf),
	\rate, Pseq([Pseries(1, 1, 20)], inf)
).play
)

(
Pbind(
	\instrument, \atari2600,
	\dur, 0.1,
	\amp, 0.8,
	\legato, 1.2,
	\tone0, 15,
	\tone1, Pseq([Pn(3, 40), Pwhite(3, 10, 8).round(3)], inf),
	\freq0, Pseq([Pn(11, 128), Pn(15, 128)], inf),
	\freq1, Pseq([10, 3, Pwrand([2, 1], [0.6, 0.4])], inf),
	\rate, Pseq([Pn(1, 8), Pn(2, 8), Pn(1, 8), Pn(Pwrand([1.1, 1.5], [0.8, 0.2]), 8)], inf)
).play
)

(
SynthDef(\nes2, {|out= 0, gate= 1, a0= 0, a1= 0, a2= 0, a3= 0, b0= 0, b1= 0, b2= 0, b3= 0, c0= 0, c2= 0, c3= 0, d0= 0, d2= 0, d3= 0, e0= 0, e1= 0, e2= 0, e3= 0, smask= 0, amp= 1, pan= 0|
	var e, z;
	e= EnvGen.kr(Env.asr(0.01, amp, 0.05), gate, doneAction:2);
	z= Nes2.ar(gate, a0, a1, a2, a3, b0, b1, b2, b3, c0, c2, c3, d0, d2, d3, e0, e1, e2, e3, smask);
	Out.ar(out, Pan2.ar(z*e, pan));
}).add;
)

(
Pbind(
	\instrument, \nes2,
	\dur, 1,
	\amp, 0.8,
	\a0, 2r10111100,
	\a1, Pseq([2r11111100, 2r11111100, 2r11110100, 2r11110100], inf),
	\a2, 2r10010000,
	\a3, Pseq([2r11111010, 2r00101011], inf),
	\smask, 2r00000001
).play
)

(
Pbind(
	\instrument, \nes2,
	\dur, 0.12,
	\amp, 0.8,
	\legato, 1.5,
	\a0, Pseq([Pn(0, 12), Pn(2r00000100, 12), Pn(0, 12), Pn(2r11000111, 12)], inf),
	\a1, Pseq([Pn(2r00000000, 32), Pn(2r11110100, 12)], inf),
	\a2, 2r00000000,
	\a3, Pseq([2r00001010, 2r00000011], inf),
	\smask, 2r00000001
).play
)

(
Pbind(
	\instrument, \nes2,
	\dur, 0.125,
	\amp, 0.8,
	\a0, Pseq([Pn(0, 12), Pn(2r00000100, 12), Pn(0, 12), Pn(2r11000111, 12)], inf),
	\a1, Pseq([Pn(2r00000000, 32), Pn(2r11110100, 12)], inf),
	\a2, 2r00000000,
	\a3, Pseq([2r00001010, 2r00000011], inf),
	\b0, 2r11100000,
	\b1, Pseq([Pn(2r00000000, 32), Pn(2r11110011, 12)], inf),
	\b2, Pseq([Pseries(255, -10, 25)], inf),
	\b3, Pseq([2r11111010, 2r11111001], inf),
	\smask, 2r00000011
).play
)

(
Pbind(
	\instrument, \nes2,
	\dur, Pbrown(0.1, 0.15, 0.1),
	\amp, 0.8,
	\d0, 2r00011000,
	\d2, Pseq([2r00001000, 2r00000111, Pseq([2r10000100, 2r10001010], 3)], inf),
	\d3, Pseq([2r11000000, 2r11100000, Pseq([2r11010000, 2r11011000], 4)], inf),
	\smask, 2r00001000
).play
)

(
Pbind(	//not working really but does produce some nice artifacts
	\instrument, \nes2,
	\dur, Pseq([0.06, 0.04], inf),
	\amp, 1,
	\e0, Pseq([Pn(2r01000000, 64), Pwhite(0, 12, 15).round(4)+2r01000000], inf),
	\e1, 2r00000000,
	\e2, 2r00000000,
	\e3, 2r00000000,
	\smask, 2r00010000
).play
)

(
SynthDef(\sn76489, {|out= 0, gate= 1, tone0= 0, tone1= 0, tone2= 0, noise= 0, vol0= 0, vol1= 0, vol2= 0, vol3= 0, rate= 1, amp= 1, pan= 0|
	var e, z;
	e= EnvGen.kr(Env.asr(0.01, amp, 0.05), gate, doneAction:2);
	z= SN76489.ar(tone0, tone1, tone2, noise, vol0, vol1, vol2, vol3, rate);
	Out.ar(out, Pan2.ar(z*e, pan));
}).add;
)


(
Pbind(
	\instrument, \sn76489,
	\dur, 0.1,
	\amp, 0.8,
	\tone0, Pseq([Pseq([10, 2], 32), Pseq([1, 9], 32), Pseq([1, 2, 4], 36)], inf)*20,
	\tone1, Pseq([Pseries(10, 14, 16), Pseries(10, 5, 16)], inf),
	\vol0, 10,
	\vol1, 10
).play
)

(
Pbind(
	\instrument, \sn76489,
	\dur, 0.25,
	\amp, 0.8,
	\tone0, Pseq([1000, 400, 500, 800], inf),
	\vol0, 10,
	\tone1, Pseq([200, 200, 600, 80], inf),
	\vol1, Pseq([Pn(0, 16), Pn(7, 16)], inf),
	\tone2, Pseq([300, 1000, 400, 1000], inf),
	\vol2, Pseq([Pn(0, 32), Pn(5, 32)], inf),
	\noise, Pseq([3, 4, 5, 6], inf),
	\vol3, Pseq([Pn(0, 64), Pn(7, 64)], inf)
).play
)

(
Pbind(
	\instrument, \sn76489,
	\dur, Pseq([0.12, 0.08], inf),
	\amp, 0.8,
	\rate, Pseq([Pn(1, 32), Pn(0.9, 32)], inf)*Pseq([Pn(1, 128), Pn(0.5, 128)], inf),
	\tone0, Pseq([10, 10, 10, 3], inf),
	\tone1, Pseq([300, 300, 300, 300, 1000], inf),
	\tone2, Pseq([10, 2, 13, 5], inf),
	\noise, Pseq([1, 2, 3], inf),
	\vol0, Pseq([Pn(10, 10), 0, 0], inf),
	\vol1, Pseq([Pn(10, 12), 0, 0], inf),
	\vol2, Pseq([Pn(10, 14), 0, 0], inf),
	\vol3, Pseq([Pn(10, 16), 0, 0], inf)
).play
)

(
Pbind(
	\instrument, \sn76489,
	\dur, Pbrown(0.1, 0.15, 0.1),
	\amp, 1,
	\tone0, 100,
	\tone1, Pseq([Pstutter(16, Pseq([200, 220])), Prand([22, 33, 44])], inf),
	\tone2, 300,
	\vol0, Pseq([9, 9, Pwrand([12, 7], [0.4, 0.6])], inf),
	\vol1, Pseq([1, 3, Pwrand([2, 1], [0.4, 0.6])], inf),
	\vol2, Pseq([2, 1, Pwrand([3, 1], [0.4, 0.6])], inf)
).play
)

(
Pbind(
	\instrument, \sn76489,
	\dur, 0.125,
	\amp, 0.8,
	\tone0, Pseq([Pn(900, 48), Pn(860, 24), Pn(1012, 24)], inf),
	\tone1, Pseq([Pn(0, 32), Pwhite(0, 8, 12)*15], inf)+602,
	\tone2, Pseq([Pn(4, 12), Pseq([86, 87, 88], 2)], inf)*100,
	\noise, Pseq([4, 3, Pwrand([2, 1], [0.6, 0.4])], inf),
	\vol0, 12,
	\vol1, Pseq([Pseries(0, 0.04, 375), Pseq([15, 0], 7)], inf),
	\vol2, Pseq([Pser([5, 3, 0], 13), Pn(8, 6), Pn(0, 3)], inf),
	\vol3, 15
).play
)

(
Pbind(
	\instrument, \sn76489,
	\dur, 0.1,
	\amp, 1,
	\legato, 1.5,
	\tone0, 20,
	\tone1, Pseq([Pn(2, 80), Pn(3, 80), Pn(4, 80), Pn(0, 40)], inf)*20,
	\tone2, Pseq([Pseries(40, 0.1, 30)], inf)*Pseq([Pn(1, 80), Pn(8, 80)], inf),
	\noise, Pseq([Pseries(1, 0.05, 100)], inf),
	\rate, Pseq([Pseries(0.25, 1, 20)], inf),
	\vol0, 10,
	\vol1, 10,
	\vol2, 4,
	\vol3, 2
).play
)

(
Pbind(
	\instrument, \sn76489,
	\dur, 0.1,
	\amp, 1,
	\legato, 1.2,
	\tone0, 15,
	\tone1, Pseq([Pn(3, 40), Pwhite(3, 10, 8).round(3)], inf),
	\tone2, 1023,
	\noise, Pseq([Pstutter(256, Pseq([1, 2, 3]))], inf),
	\vol0, 10,
	\vol1, Pseq([10, 3, Pwrand([2, 1], [0.6, 0.4])], inf),
	\vol2, Pseq([Pseq([0, 0, 0, 5], 16), Pseq([0, 2, 0, 5], 16), Pseq([Prand([5, 0, 1], 1), 2, 0, 5], inf)], inf),
	\vol3, Pseq([Pn(0, 128), Pseq([10, 0, 10, 0, 10, 8, 10], inf)], inf),
	\rate, Pseq([Pn(1, 8), Pn(2, 8), Pn(1, 8), Pn(Pwrand([1.1, 1.5], [0.8, 0.2]), 8)], inf)
).play
)

(
Ppar([
	Pbind(\instrument, \sn76489, \dur, 0.1500, \tone0, 145, \vol0, 10, \tone1, 320, \vol1, 15),
	Pbind(\instrument, \sn76489, \dur, 0.1525, \tone0, 320, \vol0, 10, \tone1, 495, \vol1, 15),
	Pbind(\instrument, \sn76489, \dur, 0.1550, \tone0, 495, \vol0, 10, \tone1, 670, \vol1, 15),
	Pbind(\instrument, \sn76489, \dur, 0.1575, \tone0, 670, \vol0, 10, \tone1, 845, \vol1, 15),
	Pbind(\instrument, \sn76489, \dur, 0.1575, \tone0, 845, \vol0, 10, \tone1, 1020, \vol1, 15)
]).play
)