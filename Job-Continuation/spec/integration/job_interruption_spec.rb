require 'rails_helper'

RSpec.describe 'Job Interruption and Resumption', type: :integration do
  describe 'Rails Native Jobs' do
    it 'supports checkpoint-based continuation' do
      expect(RailsNative::ProcessOrdersJob.ancestors).to include(ActiveJob::Continuable)
    end

    it 'can check for interruption signals' do
      job = RailsNative::ProcessOrdersJob.new
      expect(job).to respond_to(:check_interruption_flag)
      expect { job.check_interruption_flag }.not_to raise_error
    end
  end

  describe 'job-iteration Jobs' do
    it 'supports enumerator-based continuation' do
      expect(JobIteration::ProcessOrdersIterationJob.ancestors).to include(::JobIteration::Iteration)
    end

    it 'builds resumable enumerators' do
      create_list(:order, 5, status: 'pending')
      job = JobIteration::ProcessOrdersIterationJob.new

      enum_start = job.build_enumerator(cursor: nil)
      expect(enum_start).to be_a(Enumerator)
    end
  end

  describe 'Job Configuration' do
    it 'Rails Native job uses correct modules' do
      job = RailsNative::ProcessOrdersJob.new
      expect(job.class.ancestors).to include(ActiveJob::Continuable)
      expect(job.class.ancestors).to include(Interruptible)
    end

    it 'job-iteration job uses correct modules' do
      job = JobIteration::ProcessOrdersIterationJob.new
      expect(job.class.ancestors).to include(::JobIteration::Iteration)
      expect(job.class.ancestors).to include(Interruptible)
    end
  end
end
