resource "oci_core_instance" "Utility" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "CDH Utility-1"
  hostname_label      = "CDH-Utility-1"
  shape               = "${var.utility_instance_shape}"
  subnet_id           = "${var.subnet_id}"
  fault_domain	      = "FAULT-DOMAIN-3"

  source_details {
    source_type             = "image"
    source_id               = "${var.InstanceImageOCID[var.region]}"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
    user_data		= "${var.user_data}"    
  }

  timeouts {
    create = "30m"
  }
}
// Block Volume Creation for Utility 

# Log Volume for /var/log/cloudera
resource "oci_core_volume" "UtilLogVolume" {
  count               = "1"
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "Cloudera Manager ${format("%01d", count.index+1)} Log Data"
  size_in_gbs         = "${var.log_volume_size_in_gbs}"
}

resource "oci_core_volume_attachment" "UtilLogAttachment" {
  count           = "1"
  attachment_type = "iscsi"
  compartment_id  = "${var.compartment_ocid}"
  instance_id     = "${oci_core_instance.Utility.id}"
  volume_id       = "${oci_core_volume.UtilLogVolume.id}"
  device          = "/dev/oracleoci/oraclevdb"
}

# Data Volume for /opt/cloudera
resource "oci_core_volume" "UtilClouderaVolume" {
  count               = "1"
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "Cloudera Manager ${format("%01d", count.index+1)} Data"
  size_in_gbs         = "${var.cloudera_volume_size_in_gbs}"
}

resource "oci_core_volume_attachment" "UtilClouderaAttachment" {
  count           = "1"
  attachment_type = "iscsi"
  compartment_id  = "${var.compartment_ocid}"
  instance_id     = "${oci_core_instance.Utility.id}"
  volume_id       = "${oci_core_volume.UtilClouderaVolume.id}"
  device          = "/dev/oracleoci/oraclevdc"
}
