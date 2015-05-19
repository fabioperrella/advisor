require 'ostruct'

module Advisor
  module Advices
    describe CallLogger do
      subject(:advice) do
        described_class.new(object, method, args, logger: logger)
      end

      let(:object) { OpenStruct.new(id: 42) }
      let(:method) { 'the_meaning_of_life' }
      let(:args) { ['the universe', 'and everything'] }
      let(:logger) { instance_double(Logger) }

      let(:block) { -> { :bla } }

      describe '#call' do
        subject(:call) { advice.call(&block) }

        let(:log_message) do
          "[Time=#{Time.now}][Thread=#{Thread.current.object_id}][id=42]\
Called: OpenStruct#the_meaning_of_life(\"the universe\", \"and everything\")"
        end

        before do
          allow(Time).to receive(:now).and_return(Time.now)
          allow(logger).to receive(:info)
        end

        it { is_expected.to eq(:bla) }

        it do
          expect(logger).to receive(:info).with(log_message)

          call
        end

        context 'when yielding the block raises an exception' do
          let(:block) { -> () { fail 'deu ruim!' } }

          let(:log_message) do
            /\[Time=#{Time.now}\]\[Thread=#{Thread.current.object_id}\]\
\[id=42\]Failed: OpenStruct#the_meaning_of_life\(\"the universe\", \"and\
 everything\"\).*/
          end

          let(:error_message) { /^deu ruim!/ }

          before { allow(logger).to receive(:warn) }

          it { expect { call }.to raise_error(StandardError, 'deu ruim!') }

          it do
            expect(logger).to receive(:warn).with(log_message)
            expect { call }.to raise_error
          end

          it do
            expect(logger).to receive(:warn).with(error_message)
            expect { call }.to raise_error
          end
        end
      end
    end
  end
end
