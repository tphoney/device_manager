# run a test task
require 'spec_helper_acceptance'

describe 'task run_puppet_device' do
  before(:all) do
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
}
node default {}
    EOS
    make_site_pp(pp)
    run_agent(allow_changes: true)
    run_cert_reset('cisco.example.com')
    run_device_generate_csr('cisco.example.com')
    run_cert_sign('cisco.example.com')
  end
  
  it 'run_puppet_device and check fingerprint' do
    proxy_cert_name = fact('fqdn')
    result = run_task(task_name: 'device_manager::run_puppet_device', host: proxy_cert_name, params: 'target=cisco.example.com')
    # check the task was successful and contains a fingerprint
    expect_multiple_regexes(result: result, regexes: [%r{status : success}, %r{fingerprint :}])
    # with result, lets check that that fingerprints match
    # result.to contain %r{SHA1 : 42:D0:39:29:09:DD:86:5D:45:0A:FE:E8:41:06:C1:DB:0D:3C:8B:7B}
  end
end
