#!raku

# run server job on remote sparky server (sparky.local.node2)
# make it sure http traffic is routed between this server and remote one 
# port 4000
# change :api parameter according your requirements 

my $server-job = Sparky::JobApi.new: :api<http://sparky.local.node2:4000>, :project<sparky-qemu-example>;
  
$server-job.queue({
  description => "slurm server",
  tags => %(
    stage => "main",
    dump_task_code => tags()<dump_task_code> ?? "on" !! "off",
    use_case_repo => "https://gitlab.com/i.am.stack/sparky-slurm",
    qemu_binary => "qemu-kvm",
    skip_bootstrap => True,
    qemu_new_session => True,
    qemu_shut => False,
  ),
  sparrowdo => %(
    :localhost,
    :no_sudo,
    #:debug,
  ),
});

say "queue server job, ",$server-job.info.raku;

my $st = self.wait-job($server-job, %( :900timeout ) ); # wait up to 15 minutes till server job has finished 

unless $st<OK> {
  say "server job is not good";
  exit(1);
}

task-run "tasks/client"; # run client code when server is ready
