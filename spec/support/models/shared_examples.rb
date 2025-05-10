VALIDATIONS = {
  presence: "validate_presence_of",
  uniqueness: "validate_uniqueness_of",
  numericality: "validate_numericality_of",
  inclusion: "validate_inclusion_of",
  belong_to: "belong_to",
  have_many: "have_many",
  have_and_belong_to_many: "have_and_belong_to_many",
  have_one: "have_one",
  delegate: "delegate_method"
}.freeze

RSpec.shared_examples "model_shared_spec" do |factory, attribs, subj = true|
  subject { create(factory) } if subj

  it "has a valid factory" do
    expect(create(factory)).to be_valid
  end

  attribs.each do |attr|
    attr.each do |k, v|
      if v.instance_of?(Array)
        v.each do |validation|
          if validation.instance_of?(Hash)
            method = validation.keys[0]
            options = validation.values[0]

            # uniqueness validation
            if method == :uniqueness && options.is_a?(Hash)
              it "validates uniqueness of #{k} with options #{options}" do
                matcher = validate_uniqueness_of(k)
                matcher = matcher.scoped_to(*Array(options[:scope])) if options[:scope]
                matcher = matcher.case_insensitive if options[:case_sensitive] == false
                matcher = matcher.case_sensitive if options[:case_sensitive] == true
                expect(subject).to matcher
              end
            # inclusion validation
            elsif method == :inclusion && options.is_a?(Hash)
              values = options[:in]
              it { should validate_inclusion_of(k).in_array(values) }

            # numericality validation
            elsif method == :numericality
              it "validates numericality of #{k}#{options.is_a?(Hash) ? " with options #{options}" : ''}" do
                matcher = validate_numericality_of(k)

                if options.is_a?(Hash)
                  options.each do |opt, val|
                    if val == true
                      matcher = matcher.send(opt)
                    elsif val == false
                      matcher = matcher.send("not_#{opt}")
                    else
                      matcher = matcher.send("is_#{opt}", val)
                    end
                  end
                end

                expect(subject).to matcher
              end
            # other validations
            else
              it {
                expect(subject).to(
                  if options.is_a?(Array) || options.is_a?(Hash)
                    options.inject(
                      send(VALIDATIONS[method], k)
                    ) do |o, p|
                      p[1].nil? ? o.send(p[0]) : o.send(p[0], p[1])
                    end
                  else
                    send(VALIDATIONS[method], k)
                  end
                )
              }
            end
          else
            if VALIDATIONS[validation]
              it { is_expected.to(send(VALIDATIONS[validation], k)) }
            else
              warn "⚠️ Unknown validation symbol: #{validation.inspect} for attribute #{k}"
            end
          end
        end
      else
        it { is_expected.to(send(VALIDATIONS[v], k)) }
      end
    end
  end
end
