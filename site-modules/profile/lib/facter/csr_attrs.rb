Facter.add(:csr_attrs) do
  setcode do
    confdir = Facter.value(:puppet_confdir)
    csr_attr_file = "#{confdir}/csr_attributes.yaml"
    csr_attr_file
  end
end
