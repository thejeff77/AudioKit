// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AudioKit.h"

class AKModalResonanceFilterDSP : public AKSoundpipeDSPBase {
private:
    sp_mode *mode0;
    sp_mode *mode1;
    ParameterRamper frequencyRamp;
    ParameterRamper qualityFactorRamp;

public:
    AKModalResonanceFilterDSP() {
        parameters[AKModalResonanceFilterParameterFrequency] = &frequencyRamp;
        parameters[AKModalResonanceFilterParameterQualityFactor] = &qualityFactorRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_mode_create(&mode0);
        sp_mode_init(sp, mode0);
        sp_mode_create(&mode1);
        sp_mode_init(sp, mode1);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_mode_destroy(&mode0);
        sp_mode_destroy(&mode1);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_mode_init(sp, mode0);
        sp_mode_init(sp, mode1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float frequency = frequencyRamp.getAndStep();
            mode0->freq = frequency;
            mode1->freq = frequency;

            float qualityFactor = qualityFactorRamp.getAndStep();
            mode0->q = qualityFactor;
            mode1->q = qualityFactor;

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
                if (!isStarted) {
                    *out = *in;
                    continue;
                }

                if (channel == 0) {
                    sp_mode_compute(sp, mode0, in, out);
                } else {
                    sp_mode_compute(sp, mode1, in, out);
                }
            }
        }
    }
};

extern "C" AKDSPRef createModalResonanceFilterDSP() {
    return new AKModalResonanceFilterDSP();
}
