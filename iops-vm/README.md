# iaas-iops

## init

```
az login
az account set --subscription [your subscription id]
```

## deploy VMs with ultra disks
```
az deployment sub create -f 01_rg.bicep -l westeurope
az deployment group create -f vm-ultras.bicep -g msft-nl-stu-jvw-fastbox-rg
```

## deploy VMs with premium V2 storage
```
az deployment sub create -f 01_rg.bicep -l westeurope
az deployment group create -f vm-premiums.bicep -g msft-nl-stu-jvw-fastbox-rg
```

## cleanup

```
az group delete -n msft-nl-stu-jvw-fastbox-rg --yes
```


## tests

- Format Ultra disk with 64k allocation unit size - S:
- Download latest https://github.com/microsoft/diskspd/releases - extract x86 to s:\disk-spd


```
S:\disk-spd\diskspd.exe -c10G -d300 -w50 -r -t8 -o32 -b64K -h -L S:\testfile.dat > random_test_1.txt
S:\disk-spd\diskspd.exe -c10G -d300 -w50 -r -t8 -o32 -b64K -h -L S:\testfile.dat > random_test_2.txt
S:\disk-spd\diskspd.exe -c10G -d300 -w50 -r -t8 -o32 -b64K -h -L S:\testfile.dat > random_test_3.txt

S:\disk-spd\diskspd.exe -c10G -d300 -w100 -t8 -o32 -b64K -h -L S:\testfile.dat > seq_test_1.txt
S:\disk-spd\diskspd.exe -c10G -d300 -w100 -t8 -o32 -b64K -h -L S:\testfile.dat > seq_test_2.txt
S:\disk-spd\diskspd.exe -c10G -d300 -w100 -t8 -o32 -b64K -h -L S:\testfile.dat > seq_test_3.txt
```
