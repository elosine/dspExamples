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
//http://songexploder.net/anamanaguchi  start @ 1:00
//https://www.youtube.com/watch?v=aTBSQKh8teE
//live in use headphones
{ Decimator.ar( SoundIn.ar(), rate:15000, bits:6 )}.play;
{ Decimator.ar( PlayBuf.ar(2, b[9], loop:1), rate:5000, bits:8 )}.play;

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

