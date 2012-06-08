class Server
  attr_accessor :server, :compute
  def initialize(compute)
    @compute = compute
  end
end

DB_PASSWORD       = 'test'
FLAVOR = 'm1.large'
#FLAVOR = 't1.micro'
AMI    = 'ami-a4ca8df6'
ZONE   = 'ap-southeast-1b'
KEY_NAME = 'sealink'

class AmazonServer < Server
  def create
    @server = compute.servers.create(
      :image_id          => AMI,
      :flavor_id         => FLAVOR,
      :subnet_id         => 'subnet-8f37e8e6', # Virtual Private Cloud ID
      :key_name          => KEY_NAME
      :availability_zone => ZONE,
      :groups            => ['default'],
      :tags              => {'name' => 'FogTest'},
      :private_key_path  => Dir.home << '/' << KEY_FILE_NAME << '.pem'
    )
    puts @server.inspect
    @server
  end

  # Resizes a disk
  # new_size: string
  def resize_disk(new_size)
    server.stop
    puts "stopping server"
    server.wait_for{print "."; state == 'stopped'}
    
    
    small_disk = server.volumes.first

    snapshot_id = compute.create_snapshot(small_disk.id, "Snapshot for FOG TEST").body['snapshotId']
    puts "creating snapsnot"
    compute.snapshots.get(snapshot_id).wait_for { print "."; ready? }
    big_disk = compute.volumes.create(:availability_zone => ZONE, :size => new_size, :snapshot_id => snapshot_id)
    puts "create volume from snap"
    compute.volumes.get(big_disk.id).wait_for { print "."; state == 'available'}
    big_disk.reload

    small_disk.server = nil
    small_disk.destroy
    big_disk.device = '/dev/sda1'
    big_disk.server = server
    server.start
    puts "starting server"
    server.wait_for{ print "."; ready?}
    puts "started"

    server.ssh("sudo resize2fs /dev/sda1")
  end
end

class VirtualBoxServer < Server
  def create
    compute.servers.create(
      :name => 'App Server2',
      :os => 'Ubuntu')
    medium = compute.mediums.create(
      :device_type => :hard_disk,
      :location => Dir.home << '/VirtualBox VMs/App Server/NewHardDisk1.vdi',
      :read_only => false)
    storage_controller = server.storage_controllers.create(
      :bus => :sata, :name => 'sata')
    storage_controller.attach(medium, 0)

    network_adapter = server.network_adapters.first
    network_adapter
  end
end
