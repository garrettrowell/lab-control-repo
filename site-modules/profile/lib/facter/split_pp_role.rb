Facter.add('split_pp_role') do
  setcode do
    pp_role = Facter.value('trusted.extensions.pp_role')
    pp_role
  end
end
