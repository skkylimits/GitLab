targetScope = 'resourceGroup'

param location string
param disk object

resource dataDisk 'Microsoft.Compute/disks@2023-04-02' = {
	name: disk.name
	location: location
	sku: {
		name: disk.sku
	}
	properties: {
		creationData: {
			createOption: 'Empty'
		}
		diskSizeGB: disk.sizeGB
	}
}

resource dataDiskDeleteLock 'Microsoft.Authorization/locks@2020-05-01' = {
	scope: dataDisk
	name: '${disk.name}-cannot-delete'
	properties: {
		level: 'CanNotDelete'
		notes: 'Persistent GitLab data disk. Keep this disk outside the disposable VM lifecycle.'
	}
}

output dataDiskId string = dataDisk.id
