//load up some samples
b = SoundFile.collectIntoBuffers(Document.current.dir ++ "/samples/*");

//RING MODULATION
//live input, use headphones
{ SoundIn.ar() * SinOsc.ar(440) }.play
//moving carrier

//singing with myself after three seconds
(
{
var source,amplitude, freq, hasFreq;

source= SoundIn.ar;

amplitude= Amplitude.kr(source);

LPCAnalyzer.ar(source,CombC.ar(source,3.0,3.0,10.0), 256,MouseX.kr(1,256)).dup(2)

}.play
)

{LPCAnalyzer.ar(SoundIn.ar,0.1*WhiteNoise.ar, 256, MouseX.kr(1,256))}.play


{LPCAnalyzer.ar(SoundIn.ar,Impulse.ar(MouseY.kr(100,1000),0,0.2), 1024,  MouseX.kr(1,128),1,0.9999, 1)}.play


b = Buffer.read(s, "/Users/yangj14/Documents/GitHub/fluctuations4fluctuations/FullmanFluctuations3.aif");
c = Buffer.read(s, Document.current.dir/);

{ LPCAnalyzer.ar( PlayBuf.ar(2, c, loop:1), PlayBuf.ar(2, b, loop:1), 256, 256);}.play


	{ LPCAnalyzer.ar( PlayBuf.ar(2, b), Impulse.ar(440,0,0.4) , 256, 50);}.play

play({
    PitchShift.ar(
        SoundIn.ar([0, 1]),    // stereo audio input
        0.1,             // grain size
        MouseX.kr(0,2),    // mouse x controls pitch shift ratio
        0,                 // pitch dispersion
        0.004            // time dispersion
    )
}))