#!/bin/sh

prometheusDir='/etc/openstack-exporter'
configFile=${configFile:-"${prometheusDir}/openstack-exporter.yaml"}
cloudFile=${cloudFile:-"${prometheusDir}/clouds.yaml"}
listenPort=${listenPort:-9183}
debugLevel=${debugLevel:-DEBUG}
cacheRefreshInterval=${cacheRefreshInterval:-300}
cacheFileName=${cacheFileName:-"/logs/openstack-exporter/cloud-"}
cacheFileDir=/logs/openstack-exporter/
vcpuRatio=${vcpuRatio:-1.0}
ramRatio=${ramRatio:-1.0}
diskRatio=${diskRatio:-1.0}
enabledCollectors=${enabledCollectors:-cinder neutron nova}
schedulableInstanceRam=${schedulableInstanceRam:-4096}
schedulableInstanceVcpu=${schedulableInstanceVcpu:-2}
schedulableInstanceDisk=${schedulableInstanceDisk:-20}
useNovaVolumes=${useNovaVolumes:-True}
swiftHosts=${swiftHosts:-host1.example.com host2.example.com}
#keystoneTenantsMap="firstname,1234567890 secondname,0987654321"
resellerPrefix=${resellerPrefix:-AUTH_}
ringPath=${ringPath:-/etc/swift}
#hashPathPrefix=
#hashPathSuffix=

if [ ! -e "${configFile}" ]; then
    mkdir -p ${prometheusDir}
    cp prometheus-openstack-exporter.sample.yaml ${configFile}
    
    sed -i "s|VAR_LISTEN_PORT|${listenPort}|g"    ${configFile}
    sed -i "s|VAR_CACHE_REFRESH_INTERVAL|${cacheRefreshInterval}|g"   ${configFile}
    sed -i "s|VAR_CACHE_FILE|${cacheFileName}|g"    ${configFile}
    sed -i "s|DEBUG_LEVEL|${debugLevel}|g"    ${configFile}
    sed -i "s|VAR_VCPU_RATIO|${vcpuRatio}|g"    ${configFile}
    sed -i "s|VAR_RAM_RATIO|${ramRatio}|g"    ${configFile}
    sed -i "s|VAR_DISK_RATIO|${diskRatio}|g"    ${configFile}
    sed -i "s|VAR_SCHEDULABLE_INSTANCE_RAM|${schedulableInstanceRam}|g"   ${configFile}
    sed -i "s|VAR_SCHEDULABLE_INSTANCE_VCPU|${schedulableInstanceVcpu}|g"   ${configFile}
    sed -i "s|VAR_SCHEDULABLE_INSTANCE_DISK|${schedulableInstanceDisk}|g"   ${configFile}
    sed -i "s|VAR_USE_NOVA_VOLUMES|${useNovaVolumes}|g"   ${configFile}

    for i in ${enabledCollectors}; do
        sed -i "s/.*VAR_ENABLED_COLLECTORS/  - ${i}\n    - VAR_ENABLED_COLLECTORS/g" 	${configFile}
    done
    sed -i '/.*VAR_ENABLED_COLLECTORS.*/d'					${configFile} 

    for i in ${swiftHosts}; do
        sed -i "s/.*VAR_SWIFT_HOSTS/  - ${i}\n  - VAR_SWIFT_HOSTS/g" 		${configFile}
    done
    sed -i '/.*VAR_SWIFT_HOSTS.*/d'						${configFile} 

    for i in ${keystoneTenantsMap}; do
        tenantName=$(echo ${i} | cut -d',' -f1)
        tenantId=$(  echo ${i} | cut -d',' -f2)
        sed -i "s/.*VAR_KEYSTONE_TENANTS_MAP/  - ${tenantName} ${tenantId}\n  - VAR_KEYSTONE_TENANTS_MAP/g" ${configFile}
    done
    sed -i '/.*VAR_KEYSTONE_TENANTS_MAP.*/d' 					${configFile}

    sed -i "s|VAR_RESELLER_PREFIX|${resellerPrefix}|g"	 			${configFile}
    sed -i "s|VAR_RING_PATH|${ringPath}|g"	 				${configFile}
    sed -i "s|VAR_HASH_PATH_PREFIX|${hashPathPrefix}|g"	 			${configFile}
    sed -i "s|VAR_HASH_PATH_SUFFIX|${hashPathSuffix}|g"	 			${configFile}
    
    sed -i 's/VAR_.*//g'		 					${configFile}

    touch ${cacheFileName}

    cat ${configFile}
fi

mkdir -p /logs/openstack-exporter/

if [ ! -e "${cloudFile}" ]; then
    mkdir -p ${prometheusDir}
    cp clouds.yaml ${cloudFile}
fi

export OS_CLOUD_FILE=${cloudFile}

/prometheus-openstack-exporter ${configFile}

rm -rf ${cacheFileName}

exit 0
