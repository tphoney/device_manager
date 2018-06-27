require 'spec_helper_acceptance'

describe 'configure' do
  context 'basic setup' do
    it 'edit site.pp and run the agent' do
      fqdn = fact('fqdn')
      pp = <<-EOS
  node '#{fqdn}' {
    device_manager {'cisco.example.com':
      type        => 'cisco_ios',
      credentials => {
        address         => '10.64.21.10',
        port            => 22,
        username        => 'root',
        password        => 'eq3e2jM6m8AVvT9',
        enable_password => 'eq3e2jM6m8AVvT9',
      },
    }
    device_manager {'bigip.example.com':
      type         => 'f5',
      url          => 'https://admin:fffff55555@10.0.0.245/',
      run_interval => 30,
    }
  }
  node default {}
      EOS
      make_site_pp(pp)
      run_agent(allow_changes: true)
      run_agent(allow_changes: false)
    end

    # check device.conf is created
    describe file('/etc/puppetlabs/puppet/device.conf') do
      it { is_expected.to be_file }
      it { is_expected.to contain %r{[cisco.example.com]} }
      it { is_expected.to contain %r{type cisco_ios} }
      it { is_expected.to contain %r{[bigip.example.com]} }
      it { is_expected.to contain %r{type f5} }
    end
  end
end
