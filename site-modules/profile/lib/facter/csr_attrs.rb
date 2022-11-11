Facter.add(:csr_attrs) do
  setcode do
    confdir = Facter.value(:puppet_confdir)
    csr_attr_file = "#{confdir}/csr_attributes.yaml"
    parsed_file = YAML.load(File.read(csr_attr_file))
    if parsed_file.key?('extension_requests')
      parsed_file['extension_requests']
#      {
#        'pp_role' => parsed_file['extension_requests'].key?('pp_role') ? parsed_file['extension_requests']['pp_role'] : nil
#      }
    end
  end
end
