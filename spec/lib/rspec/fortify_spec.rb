require 'spec_helper'
require 'tty-command'

describe RSpec::Fortify do
  let(:cmd) { TTY::Command.new printer: :null }

  describe '#run' do
    context 'when main' do
      context 'when example changed' do
        let(:env) do
          {
            'CHANGED_SPECS' => 'spec/fixtures/flaky_test.rb,spec/fixtures/good_test.rb,spec/fixtures/bad_test.rb',
            'CI' => 'true',
            'RSPEC_FORTIFY_LOG_FIRST_ATTEMPT' => 'true',
          }
        end

        it 'retries bad test examples the configured failed retry amount' do
          out, _err = cmd.run!('bundle exec rspec spec/fixtures/bad_test.rb', env:)
          expect(out).to include('2nd try')
          expect(out).not_to include('10th try')
        end

        it 'runs good test examples once' do
          out, _err = cmd.run!('bundle exec rspec spec/fixtures/good_test.rb', env:)
          expect(out).to include('1st try')
          expect(out).not_to include('2nd try')
        end

        it 'runs flaky test examples once' do
          out, _err = cmd.run!('bundle exec rspec spec/fixtures/flaky_test.rb', env:)
          expect(out).to include('1st try')
          expect(out).not_to include('2nd try')
        end
      end

      context 'when example did not change' do
        let(:env) do
          {
            'CI' => 'true',
            'RSPEC_FORTIFY_LOG_FIRST_ATTEMPT' => 'true',
          }
        end

        it 'retries bad test examples the configured failed retry amount' do
          out, _err = cmd.run!('bundle exec rspec spec/fixtures/bad_test.rb', env:)
          expect(out).to include('2nd try')
          expect(out).not_to include('10th try')
        end

        it 'runs good test examples once' do
          out, _err = cmd.run!('bundle exec rspec spec/fixtures/good_test.rb', env:)
          expect(out).to include('1st try')
          expect(out).not_to include('2nd try')
        end

        it 'runs flaky test examples once' do
          out, _err = cmd.run!('bundle exec rspec spec/fixtures/flaky_test.rb', env:)
          expect(out).to include('1st try')
          expect(out).not_to include('2nd try')
        end
      end
    end

    context 'when pr' do
      context 'when example changed' do
        context 'when too many changed specs' do
          let(:env) do
            {
              'CHANGED_SPECS' => 'spec/fixtures/flaky_test.rb,spec/fixtures/good_test.rb,spec/fixtures/bad_test.rb,spec/fixtures/fake_test1.rb,spec/fixtures/fake_test2.rb,spec/fixtures/fake_test3.rb,spec/fixtures/fake_test4.rb,spec/fixtures/fake_test5.rb,spec/fixtures/fake_test6.rb,spec/fixtures/fake_test7.rb,spec/fixtures/fake_test8.rb,spec/fixtures/fake_test9.rb,spec/fixtures/fake_test10.rb,spec/fixtures/fake_test11.rb,spec/fixtures/fake_test12.rb,spec/fixtures/fake_test13.rb,spec/fixtures/fake_test14.rb,spec/fixtures/fake_test15.rb,spec/fixtures/fake_test16.rb,spec/fixtures/fake_test17.rb,spec/fixtures/fake_test18.rb,spec/fixtures/fake_test19.rb,spec/fixtures/fake_test20.rb,spec/fixtures/fake_test21.rb,spec/fixtures/fake_test22.rb,spec/fixtures/fake_test23.rb,spec/fixtures/fake_test24.rb,spec/fixtures/fake_test25.rb,spec/fixtures/fake_test26.rb,spec/fixtures/fake_test27.rb,spec/fixtures/fake_test28.rb,spec/fixtures/fake_test29.rb,spec/fixtures/fake_test30.rb', # rubocop:disable Layout/LineLength
              'CI' => 'true',
              'CIRCLE_PULL_REQUEST' => 'https://github.com/foo/bar/pull/123',
              'RSPEC_FORTIFY_LOG_FIRST_ATTEMPT' => 'true',
            }
          end

          it 'retries bad test examples the configured failed retry amount' do
            out, _err = cmd.run!('bundle exec rspec spec/fixtures/bad_test.rb', env:)
            expect(out).to include('2nd try')
            expect(out).not_to include('10th try')
          end

          it 'runs good test examples once' do
            out, _err = cmd.run!('bundle exec rspec spec/fixtures/good_test.rb', env:)
            expect(out).to include('1st try')
            expect(out).not_to include('2nd try')
          end

          it 'runs flaky test examples once' do
            out, _err = cmd.run!('bundle exec rspec spec/fixtures/flaky_test.rb', env:)
            expect(out).to include('1st try')
            expect(out).not_to include('2nd try')
          end
        end

        context 'when not too many changed specs' do
          let(:env) do
            {
              'CHANGED_SPECS' => 'spec/fixtures/flaky_test.rb,spec/fixtures/good_test.rb,spec/fixtures/bad_test.rb',
              'CI' => 'true',
              'CIRCLE_PULL_REQUEST' => 'https://github.com/foo/bar/pull/123',
              'RSPEC_FORTIFY_LOG_FIRST_ATTEMPT' => 'true',
            }
          end

          it 'retries bad test examples the configured failed retry amount' do
            out, _err = cmd.run!('bundle exec rspec spec/fixtures/bad_test.rb', env:)
            expect(out).to include('1st try')
            expect(out).not_to include('2nd try')
          end

          it 'retries good test examples the configured success retry amount' do
            out, _err = cmd.run!('bundle exec rspec spec/fixtures/good_test.rb', env:)
            expect(out).to include('10th try')
          end

          it 'retries flaky test examples until they flake' do
            out, _err = cmd.run!('bundle exec rspec spec/fixtures/flaky_test.rb', env:)
            expect(out).to include('2nd try')
          end
        end
      end

      context 'when example did not change' do
        let(:env) do
          {
            'CI' => 'true',
            'CIRCLE_PULL_REQUEST' => 'https://github.com/foo/bar/pull/123',
            'RSPEC_FORTIFY_LOG_FIRST_ATTEMPT' => 'true',
          }
        end

        it 'retries bad test examples the configured failed retry amount' do
          out, _err = cmd.run!('bundle exec rspec spec/fixtures/bad_test.rb', env:)
          expect(out).to include('2nd try')
          expect(out).not_to include('10th try')
        end

        it 'runs good test examples once' do
          out, _err = cmd.run!('bundle exec rspec spec/fixtures/good_test.rb', env:)
          expect(out).to include('1st try')
          expect(out).not_to include('2nd try')
        end

        it 'runs flaky test examples once' do
          out, _err = cmd.run!('bundle exec rspec spec/fixtures/flaky_test.rb', env:)
          expect(out).to include('1st try')
          expect(out).not_to include('2nd try')
        end
      end
    end

    context 'when local dev' do
      context 'when example changed' do
        let(:env) do
          {
            'CHANGED_SPECS' => 'spec/fixtures/flaky_test.rb,spec/fixtures/good_test.rb,spec/fixtures/bad_test.rb',
            'CI' => 'false',
            'RSPEC_FORTIFY_LOG_FIRST_ATTEMPT' => 'true',
          }
        end

        it 'runs bad test examples once' do
          out, _err = cmd.run!('bundle exec rspec spec/fixtures/bad_test.rb', env:)
          expect(out).to include('1st try')
          expect(out).not_to include('2nd try')
        end

        it 'runs good test examples once' do
          out, _err = cmd.run!('bundle exec rspec spec/fixtures/good_test.rb', env:)
          expect(out).to include('1st try')
          expect(out).not_to include('2nd try')
        end

        it 'runs flaky test examples once' do
          out, _err = cmd.run!('bundle exec rspec spec/fixtures/flaky_test.rb', env:)
          expect(out).to include('1st try')
          expect(out).not_to include('2nd try')
        end
      end

      context 'when example did not change' do
        let(:env) do
          {
            'CI' => 'false',
            'RSPEC_FORTIFY_LOG_FIRST_ATTEMPT' => 'true',
          }
        end

        it 'runs bad test examples once' do
          out, _err = cmd.run!('bundle exec rspec spec/fixtures/bad_test.rb', env:)
          expect(out).to include('1st try')
          expect(out).not_to include('2nd try')
        end

        it 'runs good test examples once' do
          out, _err = cmd.run!('bundle exec rspec spec/fixtures/good_test.rb', env:)
          expect(out).to include('1st try')
          expect(out).not_to include('2nd try')
        end

        it 'runs flaky test examples once' do
          out, _err = cmd.run!('bundle exec rspec spec/fixtures/flaky_test.rb', env:)
          expect(out).to include('1st try')
          expect(out).not_to include('2nd try')
        end
      end
    end
  end
end
