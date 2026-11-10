echo "Begin Uninstall!"

ACE_NAMESPACE=cp4i-ace

oc -n $ACE_NAMESPACE delete -f es-policy-temp.yaml
oc -n $ACE_NAMESPACE delete -f setdbparms-temp.yaml
oc -n $ACE_NAMESPACE delete -f server-conf-temp.yaml
oc -n $ACE_NAMESPACE delete -f truststore-temp.yaml
oc -n $ACE_NAMESPACE delete -f IntegrationRuntime-temp.yaml

echo "Uninstall Completed!"

