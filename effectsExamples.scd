//load up some samples
b = SoundFile.collectIntoBuffers(Document.current.dir ++ "/samples/*");

//AMPLITUDE MODULATION
//https://theproaudiofiles.com/the-fundamentals-of-am-synthesis/

//Mantra Exerpt
{  PlayBuf.ar(2, b[1]) }.play;

//Tremelo
SinOsc.ar(  15  ).range( 0.3, 1 );
{ SoundIn.ar() * SinOsc.ar( 15 ).range( 0, 1 ) }.play;
{ PlayBuf.ar(2, b[2], loop:1) * SinOsc.ar( LFTri.kr( SinOsc.kr(0.05).range(0.1, 0.5) ).range( 3, 20 ) ).range( 0, 1 ) }.play;

{PlayBuf.ar(2, b[2], loop:1)}.play

//Side Bands Harmonic Distortion
{ PlayBuf.ar(2, b[5], startPos: 480000, loop:1) * SinOsc.ar( 440 ).range( 0, 1 ) }.play;
{ PlayBuf.ar(2, b[5], startPos: 480000, loop:1) * SinOsc.ar( SinOsc.kr(0.005).range(30, 5000) ).range( 0, 1 ) }.play;

{PlayBuf.ar(2, b[5], startPos: 480000, loop:1) }.play;

//RING MODULATION
//"https://synthrotek.com/wp-content/uploads/2012/06/IMG_2307.jpg"
//https://enmoreaudio.com/ring-modulation-a-brief-history-of-the-original-space-age-sound/
//http://blog.calarts.edu/2018/02/28/barry-schrader-talks-bebe-barron-women-in-electronic-music-at-calarts/

//live input, use headphones
{ SoundIn.ar() * SinOsc.ar(440) }.play
//moving carrier
{ PlayBuf.ar(2, b[3], loop:1) * SinOsc.ar( LFSaw.kr(0.01).range(300, 1000) ) }.play
{ PlayBuf.ar(2, b[3], loop:1) }.play
//tremelo on carrier
{ PlayBuf.ar(2, b[3], loop:1) * ( SinOsc.ar( LFSaw.kr(0.01).range(300, 1000)  )  *  SinOsc.ar(4).range(0.2, 1) ) }.play


//LINEAR PREDICTIVE CODING/VOCODER
//https://en.wikipedia.org/wiki/Linear_predictive_coding
//Lansky Notjustmoreidlechatter https://www.youtube.com/watch?v=HYvCkfLjQFQ
//https://www.youtube.com/watch?v=tCXGJQYZ9JA
//https://www.complex.com/music/2010/08/the-50-greatest-vocoder-songs/b-plus
//https://www.youtube.com/watch?v=tFlxh9I6Bw4
//https://www.youtube.com/watch?v=5wBTdfAkqGU
//https://www.youtube.com/watch?v=uRo426va26I
//https://www.youtube.com/watch?v=UYIAfiVGluk

{ LPCAnalyzer.ar( SoundIn.ar(), PlayBuf.ar(2,b[6], rate: 1, loop:1), 256, 256);}.play
{ LPCAnalyzer.ar( PlayBuf.ar(2, b[7], loop:1), PlayBuf.ar(2, b[6], loop:1), 256, 256);}.play

{PlayBuf.ar(2, b[6], loop:1)}.play

//PITCH SHIFT
// https://www.youtube.com/watch?v=bWXazVhlyxQ     3:49
{ PitchShift.ar( PlayBuf.ar(2, b[8], loop:1), 0.1, MouseX.kr(0.1, 3), 0, 0.004 )  }.play;

//MULTI TAP DELAY
//https://www.youtube.com/watch?v=DtoKllisYdU  3:00
//https://www.youtube.com/watch?v=l2puvI4IfG0
//https://www.youtube.com/watch?v=QUD4aA2RQk0v   //tutorial video
(
c = Buffer.alloc(s, s.sampleRate*2, 1);

SynthDef(\mtap_live, {
	arg buffer, delaytimes = #[0.4, 0.6, 0.8, 1.2, 1.4, 1.6, 1.8], amps = #[1, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4], panrate=3;
	var source, sig;
	source = SoundIn.ar(0);
	sig = MultiTap.ar(delaytimes, amps, source, bufnum:buffer);
	sig = Pan2.ar(sig, SinOsc.kr(panrate));
	//sig = JPverb.ar(sig, 1.5, 0.8, 1, 0.707, 0, 0);
	Out.ar(0, sig)
}).add;

SynthDef(\mtap_buf, {
	arg buffer, sbuf, delaytimes = #[0.1, 0.3, 0.5, 0.6, 0.7, 0.8, 0.85, 0.9, 0.95, 1], amps = #[1, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 1], panrate=3;
	var source, sig;
	source = PlayBuf.ar(1, sbuf, loop:1);
	sig = MultiTap.ar(delaytimes, amps, source, bufnum:buffer);
	sig = Pan2.ar(sig, SinOsc.kr(panrate));
	//sig = JPverb.ar(sig, 1.5, 0.8, 1, 0.707, 0, 0);
	Out.ar(0, sig)
}).add;
)


x = Synth(\mtap_live, [ \buffer, c] ] );
y = Synth(\mtap_buf, [ \buffer, c, \panrate, 0.2, \sbuf, b[9], \delaytimes, [0.05, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5, 0.7, 0.9, 1.1], \amps, [1, 0.95, 0.9, 0.85, 0.8, 0.75, 0.7, 0.65, 0.6, 1] ] );


	