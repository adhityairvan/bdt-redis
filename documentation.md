---


---

<h1 id="implementasi-redis-cluster">Implementasi Redis Cluster</h1>
<p>Implementasi dan tutorial pembuatan cluster redis.<br>
dokumentasi ini akan dibuat dengan <strong>Elementary OS</strong>, <strong>Vagrant</strong>, <strong>Ubuntu 18.04</strong> sebagai vagrant image nya.</p>
<h2 id="persiapan">Persiapan</h2>
<p>Dalam tahap persiapan, akan dibuat <strong>VagrantFile</strong> yang akan memudahkan dalam pembuatan virtual machine ubuntu.<br>
Akan dibuat 3 Virtual machine</p>

<table>
<thead>
<tr>
<th>clusterName</th>
<th>IP</th>
<th>Role</th>
</tr>
</thead>
<tbody>
<tr>
<td>rediscluster1</td>
<td>10.10.15.153</td>
<td>Master + sentinel</td>
</tr>
<tr>
<td>rediscluster2</td>
<td>10.10.15.154</td>
<td>Slave + sentinel</td>
</tr>
<tr>
<td>rediscluster3</td>
<td>10.10.15.155</td>
<td>Slave + sentinel</td>
</tr>
</tbody>
</table><h3 id="konfigurasi-vagrant">Konfigurasi Vagrant</h3>
<pre><code>Vagrant.configure("2") do |config|
  (1..3).each do |i|
    config.vm.define "rediscluster#{i}" do |node|
      node.vm.hostname = "rediscluster#{i}"
      node.vm.box = "bento/ubuntu-18.04"
      node.vm.network "private_network", ip: "10.10.15.#{142 + i}"
      node.vm.provider "virtualbox" do |vb|
        vb.name = "rediscluster#{i}"
        vb.gui = false
        vb.memory = "512"
      end

      node.vm.provision "shell", path: "bootstrap.sh", privileged: false
    end
  end
end
</code></pre>
<h2 id="instalisasi">Instalisasi</h2>
<p>Redis-server akan diinstall disetiap vagrant machine<br>
command yang dijalankan:</p>
<pre><code>sudo apt-get update -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:chris-lea/redis-server -y
sudo apt-get install redis-server -y
sudo systemctl enable redis-server.service
</code></pre>
<p>buka firewall untuk port default redis</p>
<pre><code>sudo ufw allow 6379
sudo ufw allow 26379
</code></pre>
<p>untuk mempermudah setup pada setiap virtual machine, membuat provision script yang dijalankan setiap setup virtual machine sangat disarankan</p>
<h2 id="konfigurasi-redis">Konfigurasi Redis</h2>
<p>Ada 2 hal yang perlu kita konfigurasi</p>
<ol>
<li>Redis server</li>
<li>Sentinel Server</li>
</ol>
<p>Redis server akan kita setup menjadi dua tipe, master dan slave.<br>
sedangkan sentinel server akan kita buat di seluruh node yang ada</p>
<h3 id="konfigurasi-master">Konfigurasi Master</h3>
<p>lakukan perintah dibawah untuk mengkonfigurasi master node<br>
edit file konfigurasi yang ada pada directory redis<br>
<strong>redis.conf</strong></p>
<pre><code>#cari dan rubah opsi pada file redis.conf
#comment line yang berisi "bind 127.0.0.1 ::1"
protected-mode no 
</code></pre>
<h3 id="konfigurasi-slave">Konfigurasi Slave</h3>
<p><em><strong>redis.conf</strong></em></p>
<pre><code>protected-mode no
#comment line yang berisi "bind 127.0.0.1 ::1"
slaveof 192.168.33.11 6379
#ganti ip nya agar sesuai dengan ip master node
</code></pre>
<h3 id="konfigurasi-sentinel">konfigurasi Sentinel</h3>
<p>download file default konfigurasi sentinel</p>
<pre><code>wget http://download.redis.io/redis-stable/sentinel.conf
cp sentinel.conf /etc/redis/
</code></pre>
<p>rubah opsi dalam file tsb</p>
<p><em><strong>sentinel.conf</strong></em></p>
<pre><code>sentinel monitor mymaster 192.168.33.11 6379 2
sentinel down-after-milliseconds 5000
sentinel failover-timeout mymaster 10000
</code></pre>
<p>opsi diatas menentukan master node nya dan syarat waktu untuk mengenali sebuah master node mati atau timeout</p>
<p>Buat lah sentinel.conf di setiap node, buat 2 slave node dan satu master node</p>
<h2 id="menjalankan-server-redis">Menjalankan server redis</h2>
<p>jalankan command di bawah pada setiap node</p>
<pre><code>sudo -u redis redis-server /etc/redis/redis.conf &amp;
sudo -u redis redis-server /etc/redis/sentinel.conf &amp;
</code></pre>
<p>`command di atas akan menjalankan sentinel dan server redis<br>

atau juga bisa membuat service baru untuk menjalankan secara otomatis redis sentinel nya

<h2 id="ujicoba-crud-pada-master">Ujicoba CRUD pada master</h2>
<p>uji coba ini akan dilakukan pada node master dengan memasukan dan melihat key yang ada<br>

<h2 id="hasil-simulasi-fail-over">Hasil simulasi Fail Over</h2>
<p>menghentikan master node<br>
```
  sudo systemctl stop redis
```
<p>respon dari sentinel saat master node mati<br>
![](https://github.com/adhityairvan/bdt-redis/raw/master/image/Annotation%202019-11-23%20195612.jpg)
  
<p>salah satu slave node berubah menjadi master node<br>
![](https://github.com/adhityairvan/bdt-redis/raw/master/image/master.jpg)

# IMPLEMENTASI WORDPRESS
## Membuat Server LAMP untuk menjalankan wordpress
```
config.vm.define "apache" do |node|
    node.vm.hostname = "apacheserver"
    node.vm.box = "bento/ubuntu-18.04"
    node.vm.network "private_network", ip: "10.10.15.146"
    node.vm.network "forwarded_port", guest: 80, host: 8080
    node.vm.provider "virtualbox" do |vb|
        vb.name = "apacheserver"
        vb.gui = false
        vb.memory = "1024"
    end
end
```

Lakukan install beberapa applikasi berikut
1. Apache
2. PHP
3. Mysql
4. php redis plugin
Untuk panduan menginstall 3 applikasi diatas, bisa di baca disini
https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-lamp-on-ubuntu-18-04

## Install Wordpress
referensi : https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-lamp-on-ubuntu-18-04

1. Download Zip wordpress dan extract di /var/www
2. Edit file config wordpress nya agar menunjuk database mysql yang sudah di buat
3. Sesuaikan settingan virtual host pada apache2

## Install Redis Plugin pada wordpress
1. Install plugin redis object cache pada wordpress
2. buka file configurasi wordpress dan tambahkan line berikut diakhir file
```
define( 'WP_REDIS_CLIENT', 'predis' );
define( 'WP_REDIS_SENTINEL', 'mymaster' );
define( 'WP_REDIS_SERVERS', [
    'tcp://10.10.15.143:26379',
    'tcp://10.10.15.143:26379',
    'tcp://10.10.15.143:26379',
] );
```
perhatikan pada bagian ip, kita mengakses redis sentinel service nya, bukan redis server nya langsung
3. Enable redis plugin pada wordpress pada menu setting di halaman admin wordpress


## Pengujian Load Server
Terdapat 3 skenario pengujian
1. 50 Request
2. 243 Request
3. 343 Request

### Hasil Pengujian 50 Request
Wordpress Dengan Redis cache
![](https://github.com/adhityairvan/bdt-redis/raw/master/image/redis50.jpg)
Wordpress Tanpa Redis cache
![](https://github.com/adhityairvan/bdt-redis/raw/master/image/no%20redis-50.jpg)
Pada dua gambar diaatas dapat kita lihat bahwa tidak terdapat banyak perbedaan karena resource ram dan cpu pada webserver masih mumpuni untuk menghandle request nya

### Hasil Pengujian 243 Request
Wordpress Dengan Redis cache
![](https://github.com/adhityairvan/bdt-redis/raw/master/image/redis100.jpg)
Wordpress Tanpa Redis cache
![](https://github.com/adhityairvan/bdt-redis/raw/master/image/no%20redis%20200.jpg)
Hasil serupa dapat kita lihat pada pengujian 243 Request ini. Ada sedikit perbedaan dengan redis rata2 sample time lebih cepat 10ms.

### Hasil Pengujian 343 Request
Wordpress Dengan Redis cache
![](https://github.com/adhityairvan/bdt-redis/raw/master/image/redis200.jpg)
Wordpress Tanpa Redis cache
![](https://github.com/adhityairvan/bdt-redis/raw/master/image/no%20redis-200.jpg)
Perbedaan signifikan baru terlihat dengan 343 request. Pada server yang tidak terpasang redis, terlihat virtual machine nya kewalahan dan menghabiskan resource ram yang ada. Hal ini terjadi karena Webserver banyak melakukan request ke database dan database juga membutuhkan tambahan memori untuk menghandle request yang ada.
