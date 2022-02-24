# Installing the tools and components

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y build-essential git vim-nox wget curl

# Installing PostgreSQL
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y postgresql-12 postgresql-contrib-12 libpq-dev postgis postgresql-12-postgis-3
sudo apt-get install -y gdal-bin libspatialindex-dev libgeos-dev libproj-dev

# Installing Colouring London
cd ~ && git clone https://github.com/colouring-london/colouring-london.git

# Installing Node.js
export NODE_VERSION=v16.13.2
export DISTRO=linux-x64
wget -nc https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-$DISTRO.tar.xz
sudo mkdir /usr/local/lib/node
sudo tar xf node-$NODE_VERSION-$DISTRO.tar.xz -C /usr/local/lib/node
sudo mv /usr/local/lib/node/node-$NODE_VERSION-$DISTRO /usr/local/lib/node/node-$NODE_VERSION
rm node-$NODE_VERSION-$DISTRO.tar.xz

cat >> ~/.profile <<EOF
export NODEJS_HOME=/usr/local/lib/node/node-$NODE_VERSION/bin
export PATH=\$NODEJS_HOME:\$PATH
EOF

source ~/.profile

echo $PATH
echo $NODEJS_HOME

# Configuring PostgreSQL
service postgresql start
sudo locale-gen en_US.UTF-8
sudo sed -i "s/#\?listen_address.*/listen_addresses '*'/" /etc/postgresql/12/main/postgresql.conf
echo "host    all             all             all                     md5" | sudo tee --append /etc/postgresql/12/main/pg_hba.conf > /dev/null
sudo -u postgres psql -c "SELECT 1 FROM pg_user WHERE usename = 'username';" | grep -q 1 || sudo -u postgres psql -c "CREATE ROLE username SUPERUSER LOGIN PASSWORD 'pgpassword';"

service postgresql restart

export PGPASSWORD=pgpassword
export PGUSER=username
export PGHOST=localhost
export PGDATABASE=colouringlondondb

sudo -u postgres psql -c "SELECT 1 FROM pg_database WHERE datname = 'colouringlondondb';" | grep -q 1 || sudo -u postgres createdb -E UTF8 -T template0 --locale=en_US.utf8 -O username colouringlondondb

echo "Run psql interactively."
echo "Run psql interactively."
echo "Run psql interactively."
echo "Run psql interactively."
echo "Run psql interactively."
echo "Run psql interactively."
echo "Run psql interactively."
echo "Run psql interactively."
echo "Run psql interactively."
echo "Run psql interactively."
echo "Run psql interactively."
echo "Run psql interactively."

# Configuring Node.js
sudo su root
export NODEJS_HOME=/usr/local/lib/node/node-v16.13.2/bin/
export PATH=$NODEJS_HOME:$PATH
npm install -g npm@latest
exit

cd ~/colouring-london/app
npm install

# Loading the building data (OpenStreetMap test polygons)

sudo apt-get install -y python3 python3-pip python3-dev python3-venv
pyvenv colouringlondon
source colouringlondon/bin/activate

pip install --upgrade pip
pip install --upgrade setuptools wheel
sudo apt-get install -y parallel

cd ~/colouring-london/etl/
pip install -r requirements.txt

python get_test_polygons.py

ls ~/colouring-london/migrations/*.up.sql 2>/dev/null | while read -r migration; do psql -d colouringlondondb < $migration; done;

./load_geometries.sh ./
./create_building_records.sh

# Running the application

cd ~/colouring-london/app
mkdir tilecache
export PGPORT=5432
export APP_COOKIE_SECRET=123456
export TILECACHE_PATH=~/colouring-london/app/tilecache
npm start

# PGPASSWORD=pgpassword PGDATABASE=colouringlondondb PGUSER=username PGHOST=localhost PGPORT=5432 APP_COOKIE_SECRET=123456 TILECACHE_PATH=~/colouring-london/app/tilecache npm start 
# ?????
