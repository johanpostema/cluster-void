set -e

if [ ! -f install-config.yaml ]; then
  echo "Error: esnure install-config.yaml exists"
  exit 1
fi
if [ -e fcos-live.iso ] || [ -e sno ]; then
  echo "Error: ensore fcos-live.iso en sno directory are not present"
  exit 1
fi

echo "Download fcos iso"
ISO_URL=$(openshift-install coreos print-stream-json | jq -r .architectures.x86_64.artifacts.metal.formats.iso.disk.location)
curl -L "$ISO_URL" -o fcos-live.iso

echo
echo "create sno workdir and generate manifest and ignition file"
mkdir sno
cp install-config.yaml sno/
openshift-install --dir=sno create single-node-ignition-config

echo
echo "Done. Please run on linux podman to embed the ignition file into the iso"
echo "To do this, on linux run: "
echo "# embed de ignition data in de fcos-iso"
echo "alias coreos-installer='podman run --privileged --pull always --rm -v /dev:/dev -v /run/udev:/run/udev -v \$PWD:/data -w /data quay.io/coreos/coreos-installer:release'"
echo "coreos-installer iso ignition embed -fi sno/bootstrap-in-place-for-live-iso.ign fcos-live.iso"
