Puppet::Functions.create_function(:'deployments::report_scm_data') do
  dispatch :report_scm_data do
    required_param 'Hash', :pipeline
    required_param 'String', :merge_approver
  end

  def report_scm_data(pipeline, merge_approver)
    report = {}
    report['scm'] = {}
    report['scm']['url'] = if pipeline['triggerType'] == 'VERSION_CONTROL_PUSH'
                             pipeline['webhookEvent']['repoUrl']
                           else
                             ''
                           end
    report['scm']['branch']      = pipeline['branch']
    report['scm']['commit']      = pipeline['commitId']
    report['scm']['changes']     = []
    report['scm']['culprits']    = []
    report['scm']['description'] = pipeline['description']
    report['scm']['merge_approver'] = merge_approver
    report
  end
end
