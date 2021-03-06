require 'spec_helper'

require './lib/core'

describe 'Core' do

  context 'get_ps_stats' do
    it 'returns mem and cpu' do
      allow(self).to receive(:`) {
        %Q{12362 65764 0,0
           12366 65732 0,0
           12370 65708 0,0
           12372 65780 0,0}
      }

      expect(get_ps_stats([12362, 12366, 12370, 12372])).to eq({
        12362 => { mem: 64, pcpu: 0.0 },
        12366 => { mem: 64, pcpu: 0.0 },
        12370 => { mem: 64, pcpu: 0.0 },
        12372 => { mem: 64, pcpu: 0.0 }
      })
    end
  end


  context 'hydrate_stats' do
    before(:each) do
      allow(self).to receive(:get_ps_stats) { {} }
    end

    it 'adds the main pid and state_file_path' do
      stats = Stats.new({ 'worker_status' => [] })
      hydrate_stats(stats, { 'pid' => '1234' }, 'test')

      expect(stats.pid).to eq('1234')
      expect(stats.state_file_path).to eq('test')
    end
  end

  context 'display_stats' do

    before do
      Timecop.freeze(Time.parse('2019-07-14T10:49:24Z'))
    end

    after do
      Timecop.return
    end

    it 'works in clusted mode' do
      stats = {"started_at"=>"2019-07-14T10:49:24Z", "workers"=>4, "phase"=>0, "booted_workers"=>4, "old_workers"=>0, "worker_status"=>[{"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12362, "index"=>0, "phase"=>0, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12366, "index"=>1, "phase"=>0, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12370, "index"=>2, "phase"=>0, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12372, "index"=>3, "phase"=>0, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}], "pid"=>12328, "state_file_path"=>"../testpuma/tmp/puma.state"}

      ClimateControl.modify NO_COLOR: '1' do
        expect(format_stats(Stats.new(stats))).to eq(
%Q{12328 (../testpuma/tmp/puma.state) Uptime:  0m 0s | Phase: 0 | Load: 0[░░░░░░░░░░░░░░░░]16
 └ 12362 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4
 └ 12366 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4
 └ 12370 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4
 └ 12372 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4})
      end
    end

      context 'with few running threads' do
        stats = {"started_at"=>"2019-07-14T10:49:24Z", "workers"=>4, "phase"=>0, "booted_workers"=>4, "old_workers"=>0, "worker_status"=>[{"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12362, "index"=>0, "phase"=>0, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>1, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12366, "index"=>1, "phase"=>0, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>1, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12370, "index"=>2, "phase"=>0, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>1, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12372, "index"=>3, "phase"=>0, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>1, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}], "pid"=>12328, "state_file_path"=>"../testpuma/tmp/puma.state"}


      it 'displays the right amount of max threads' do
        ClimateControl.modify NO_COLOR: '1' do
          expect(format_stats(Stats.new(stats))).to eq(
%Q{12328 (../testpuma/tmp/puma.state) Uptime:  0m 0s | Phase: 0 | Load: 0[░░░░░░░░░░░░░░░░]16
 └ 12362 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4
 └ 12366 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4
 └ 12370 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4
 └ 12372 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4})
          end
        end
    end

    it 'works in clusted mode during phased restart' do
      stats = {"started_at"=>"2019-07-14T10:49:24Z", "workers"=>4, "phase"=>1, "booted_workers"=>4, "old_workers"=>0, "worker_status"=>[{"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12362, "index"=>0, "phase"=>0, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12366, "index"=>1, "phase"=>0, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12370, "index"=>2, "phase"=>1, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12372, "index"=>3, "phase"=>1, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}], "pid"=>12328, "state_file_path"=>"../testpuma/tmp/puma.state"}

      ClimateControl.modify NO_COLOR: '1' do
        expect(format_stats(Stats.new(stats))).to eq(
%Q{12328 (../testpuma/tmp/puma.state) Uptime:  0m 0s | Phase: 1 | Load: 0[░░░░░░░░░░░░░░░░]16
 └ 12362 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4 | Phase: 0
 └ 12366 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4 | Phase: 0
 └ 12370 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4
 └ 12372 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4})
      end
    end

    it 'shows killed workers' do
      stats = {"started_at"=>"2019-07-14T10:49:24Z", "workers"=>4, "phase"=>1, "booted_workers"=>4, "old_workers"=>0, "worker_status"=>[{"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12362, "index"=>0, "phase"=>1, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12366, "index"=>1, "phase"=>1, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12370, "index"=>2, "phase"=>1, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12372, "index"=>3, "phase"=>1, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}], "pid"=>12328, "state_file_path"=>"../testpuma/tmp/puma.state"}

      ClimateControl.modify NO_COLOR: '1' do
        stats = Stats.new(stats)
        allow(stats.workers.first).to receive(:booting?) { false }
        allow(stats.workers.first).to receive(:killed?) { true }

        expect(format_stats(stats)).to eq(
%Q{12328 (../testpuma/tmp/puma.state) Uptime:  0m 0s | Phase: 1 | Load: 0[░░░░░░░░░░░░░░░░]16
 └ 12362 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s killed
 └ 12366 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4
 └ 12370 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4
 └ 12372 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4})
      end
    end

    it 'shows booting workers' do
      stats = {"started_at"=>"2019-07-14T10:49:24Z", "workers"=>4, "phase"=>1, "booted_workers"=>4, "old_workers"=>0, "worker_status"=>[{"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12362, "index"=>0, "phase"=>1, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12366, "index"=>1, "phase"=>1, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12370, "index"=>2, "phase"=>1, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12372, "index"=>3, "phase"=>1, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}], "pid"=>12328, "state_file_path"=>"../testpuma/tmp/puma.state"}

      ClimateControl.modify NO_COLOR: '1' do
        stats = Stats.new(stats)
        allow(stats.workers.first).to receive(:booting?) { true }

        expect(format_stats(stats)).to eq(
%Q{12328 (../testpuma/tmp/puma.state) Uptime:  0m 0s | Phase: 1 | Load: 0[░░░░░░░░░░░░░░░░]16
 └ 12362 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s booting
 └ 12366 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4
 └ 12370 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4
 └ 12372 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4})
      end
    end

    it 'shows the master process booting' do
      stats = {"started_at"=>"2019-07-14T10:49:24Z", "workers"=>4, "phase"=>1, "booted_workers"=>4, "old_workers"=>0, "worker_status"=>[{"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12362, "index"=>0, "phase"=>1, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12366, "index"=>1, "phase"=>1, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12370, "index"=>2, "phase"=>1, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12372, "index"=>3, "phase"=>1, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4}, "mem"=>64, "pcpu"=>0.0}], "pid"=>12328, "state_file_path"=>"../testpuma/tmp/puma.state"}

      ClimateControl.modify NO_COLOR: '1' do
        stats = Stats.new(stats)
        allow_any_instance_of(Stats::Worker).to receive(:booting?) { true }

        expect(format_stats(stats)).to eq(
%Q{12328 (../testpuma/tmp/puma.state) Uptime:  0m 0s | Phase: 1 booting
 └ 12362 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s booting
 └ 12366 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s booting
 └ 12370 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s booting
 └ 12372 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s booting})
      end
    end

    it 'show the number of request when present in clustered mode' do
      stats = {"started_at"=>"2019-07-14T10:49:24Z", "workers"=>4, "phase"=>0, "booted_workers"=>4, "old_workers"=>0, "worker_status"=>[{"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12362, "index"=>0, "phase"=>0, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4, "requests_count"=>150}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12366, "index"=>1, "phase"=>0, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4, "requests_count"=>223}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12370, "index"=>2, "phase"=>0, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4, "requests_count"=>450}, "mem"=>64, "pcpu"=>0.0}, {"started_at"=>"2019-07-14T10:49:24Z", "pid"=>12372, "index"=>3, "phase"=>0, "booted"=>true, "last_checkin"=>"2019-07-14T13:09:00Z", "last_status"=>{"backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4, "requests_count"=>10}, "mem"=>64, "pcpu"=>0.0}], "pid"=>12328, "state_file_path"=>"../testpuma/tmp/puma.state"}

      ClimateControl.modify NO_COLOR: '1' do
        expect(format_stats(Stats.new(stats))).to eq(
%Q{12328 (../testpuma/tmp/puma.state) Uptime:  0m 0s | Phase: 0 | Load: 0[░░░░░░░░░░░░░░░░]16 | Req: 833
 └ 12362 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4 | Req: 150
 └ 12366 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4 | Req: 223
 └ 12370 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4 | Req: 450
 └ 12372 CPU:   0.0% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4 | Req: 10})
      end
    end

    it 'works in single mode' do
      stats = {"started_at"=>"2019-07-14T10:49:24Z", "backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4, "pid"=>21725, "state_file_path"=>"../testpuma/tmp/puma.state", "pcpu"=>10, "mem"=>64}

      ClimateControl.modify NO_COLOR: '1' do
        expect(format_stats(Stats.new(stats))).to eq(
%Q{21725 (../testpuma/tmp/puma.state) Uptime:  0m 0s | Load: 0[░░░░]4
 └ 21725 CPU:    10% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4})
      end
    end

    it 'show the number of request when present in single mode' do
      stats = {"started_at"=>"2019-07-14T10:49:24Z", "backlog"=>0, "running"=>4, "pool_capacity"=>4, "max_threads"=>4, "pid"=>21725, "state_file_path"=>"../testpuma/tmp/puma.state", "pcpu"=>10, "mem"=>64, "requests_count"=> 150}

      ClimateControl.modify NO_COLOR: '1' do
        expect(format_stats(Stats.new(stats))).to eq(
%Q{21725 (../testpuma/tmp/puma.state) Uptime:  0m 0s | Load: 0[░░░░]4 | Req: 150
 └ 21725 CPU:    10% Mem:   64 MB Uptime:  0m 0s | Load: 0[░░░░]4 | Req: 150})
      end
    end
  end
end
