Facter.add(:csr_attrs) do
  setcode do
    confdir = Facter.value(:puppet_confdir)
    csr_attr_file = "#{confdir}/csr_attributes.yaml"

    if File.file?(csr_attr_file)
      parsed_file = YAML.load(File.read(csr_attr_file))
      if parsed_file.key?('extension_requests')
        parsed_file['extension_requests']
        if parsed_file['extension_requests'].key?('pp_role')
          parsed_file['extension_requests']['pp_role'].split('::')
        end # if pp_role
      end # if extension requests
    end # if file exists
  end # setcode do
end # facter.add
