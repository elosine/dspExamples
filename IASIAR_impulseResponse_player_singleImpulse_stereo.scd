
(//1
// SET INITIAL SERVER CONDITIONS & BOOT SERVER ////////////////////////////////////////////////
s.options.memSize = 1000000; //1gb memory
s.boot;
)
(//3
// PROCESS IMPULSES ////////////////////////////////////////////////
//wait several seconds for this to complete
fork{

	~path_L = thisProcess.nowExecutingPath.dirname +/+ "impulses_L"; //should point to a folder called "impulses" in the same folder that this document is in
	~impulsenames_L = (~path_L +/+ "*").pathMatch;  //will generate an Array with the path to all of the impulse files
	~numImpulses = ~impulsenames_L.size;  //get number of impulses from the generated ~impulsenames array
	~irSpectrums_L = Array.newClear(~numImpulses); //make an array to hold all of the impulse response spectrum buffers

	~path_R = thisProcess.nowExecutingPath.dirname +/+ "impulses_R";
	~impulsenames_R = (~path_R +/+ "*").pathMatch;
	~irSpectrums_R = Array.newClear(~numImpulses);

	b = SoundFile.collectIntoBuffers(Document.current.dir ++ "/samples/*");

	2.wait;

	SynthDef( "IASIAR_live", {
		arg outBus=0, in=0, amp=0.4, inAmp=0.4, fftSize=2048, spectrumBufnumL=0, spectrumBufnumR=0, atk=0.03, sus=1.0, rel=3.1, crv=0, gate=1;
		var input, outputL, outputR, env;
		env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate, doneAction:2 );
		input = SoundIn.ar(in)*inAmp;
		outputL = PartConv.ar( input, fftSize, spectrumBufnumL );
		outputR = PartConv.ar( input, fftSize, spectrumBufnumR );
		Out.ar( outBus, [outputL, outputR]*amp*env );
	}).add;

	SynthDef( "IASIAR_buffer", {
		arg outBus=0, in=0, amp=0.4, inAmp=0.4, fftSize=2048, spectrumBufnumL=0, spectrumBufnumR=0, atk=0.03, sus=1.0, rel=3.1, crv=0, gate=1, buf;
		var input, outputL, outputR, env;
		env = EnvGen.ar( Env.asr(atk, 1, rel, crv), gate, doneAction:2 );
		input = PlayBuf.ar(2, buf, loop:1)*inAmp;
		outputL = PartConv.ar( input, fftSize, spectrumBufnumL );
		outputR = PartConv.ar( input, fftSize, spectrumBufnumR );
		Out.ar( outBus, [outputL, outputR]*amp*env );
	}).add;

	//Prepare Impulse Response Buffers
	fork{
		~numImpulses.do{ |ix|
			var irbuffer, bufsize;
			irbuffer = Buffer.read(s, ~impulsenames_L[ix] );  //Read impulse response into a temporary buffer
			s.sync;
			bufsize = PartConv.calcBufSize(2048, irbuffer);  //Calculate buffer size for the spectrum of the buffer
			~irSpectrums_L[ix] = Buffer.alloc(s, bufsize, 1); //All1ocate a buffer for the ir spectrum
			~irSpectrums_L[ix].preparePartConv(irbuffer, 2048); //Make spectral buffer and store in Array
			s.sync;
			irbuffer.free;  //free temp buffer

			1.5.wait; //Might have to increase this as the above takes a while depending on processor speed
		};
		20.wait;
		~numImpulses.do{ |ix|
			var irbuffer, bufsize;
			irbuffer = Buffer.read(s, ~impulsenames_R[ix] );  //Read impulse response into a temporary buffer
			s.sync;
			bufsize = PartConv.calcBufSize(2048, irbuffer);  //Calculate buffer size for the spectrum of the buffer
			~irSpectrums_R[ix] = Buffer.alloc(s, bufsize, 1); //Allocate a buffer for the ir spectrum
			~irSpectrums_R[ix].preparePartConv(irbuffer, 2048); //Make spectral buffer and store in Array
			s.sync;
			irbuffer.free;  //free temp buffer

			1.5.wait; //Might have to increase this as the above takes a while depending on processor speed
		};
	};
})

//3 WAIT ABOUT A MINUTE FOR ALL THE IMPULSES TO BE PROCESSED

//4 USE THE REVERB
//Impulses are in the folders 'impulses_L' and 'impulses_R'
//To add your own impulses:
////Find a stereo impulse
////Split it into two mono sound files, left & right using a program like Audacity https://www.audacityteam.org/
////Add the left sound file to the folder 'impulses_L' and the right sound file to 'impulses_R'
//Add your own samples to process to the folder 'samples'

//for live input, use headphones
x = Synth( \IASIAR_live, [ \spectrumBufnumL, ~irSpectrums_L[0].bufnum, \spectrumBufnumR, ~irSpectrums_R[0].bufnum ] );
//for sound buffer
y = Synth( \IASIAR_buffer, [ \buf, b[10], \spectrumBufnumL, ~irSpectrums_L[4].bufnum, \spectrumBufnumR, ~irSpectrums_R[4].bufnum ] );

x.free;
y.free;


//change impulse by changing the number in ~irSpectrums: ~irSpectrums_L[3].bufnum, ~irSpectrums_R[3].bufnum
//change sound file in y by changing the number in \buf, b[] as in b[3]
//List of included impulses:
/*
000_Hamilton_Mausoleum_L
001_R1_Nuclear_Reactor_Hall_s_L
002_falkland_tennis_court_s_L
003_york_minster_s_L
004_abernyte_grain_silo_s_L
005_SquareVictoriaDome_s_L
006_EchoBridge_s_L
007_WalkwayUnderECampusDr_s_L
008_3000CStreetGarageStairwell_s_L
009_danHarpoleCistern_L
010_longestEcho
011_ScalaMilanOperaHall_L
*/
