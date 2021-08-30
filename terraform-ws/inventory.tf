resource "null_resource" "inventory_creation" {
    
    depends_on = [
      aws_instance.aws_hadoop_master,
      azurerm_linux_virtual_machine.az_hadoop_slave,
      google_compute_instance.gcp_hadoop_slave
    ]

provisioner "local-exec" {
  command = <<EOT
cat <<EOF > ../ansible-ws/inventory
[aws_hadoop_namenode]
${aws_instance.aws_hadoop_master[0].public_ip}

[aws_hadoop_jobtracker]
${aws_instance.aws_hadoop_master[1].public_ip}

[az_gcp_hadoop_datanode]
${google_compute_instance.gcp_hadoop_slave[0].network_interface.0.access_config.0.nat_ip}
${azurerm_linux_virtual_machine.az_hadoop_slave["hadoop-datanode"].public_ip_address}

[az_gcp_hadoop_tasktracker]
${google_compute_instance.gcp_hadoop_slave[1].network_interface.0.access_config.0.nat_ip}
${azurerm_linux_virtual_machine.az_hadoop_slave["hadoop-tasktracker"].public_ip_address}

[hadoop_client_node]
192.168.99.103
EOF
    EOT
  }
}