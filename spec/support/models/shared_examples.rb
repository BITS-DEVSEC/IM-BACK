VALIDATIONS = {
  presence: "validate_presence_of",
  uniqueness: "validate_uniqueness_of",
  numericality: "validate_numericality_of",
  inclusion: "validate_inclusion_of",
  belong_to: "belong_to",
  have_many: "have_many",
  have_and_belong_to_many: "have_and_belong_to_many",
  have_one: "have_one",
  delegate: "delegate_method",
  optional: "optional"
}.freeze

CONTENT_TYPE_EXTENSIONS = {
  'image/jpeg' => '.jpg',
  'image/png' => '.png',
  'application/pdf' => '.pdf',
  'video/mp4' => '.mp4',
  'video/mpeg' => '.mpeg'
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

            # attachment validation (content type)
            elsif method == :content_type && options.is_a?(Hash)
              allowed_types = options[:allowed] || options
              message = options[:message] || "must be a #{allowed_types.join(' or ')}"
              it "validates content type of #{k} to be one of #{allowed_types.join(' or ')}" do
                file = Tempfile.new([ 'invalid', '.txt' ])
                file.write('text')
                file.rewind
                subject.send(k).attach(io: file, filename: 'invalid.txt', content_type: 'text/plain')
                subject.valid?
                expect(subject.errors[k]).to include(message)
              ensure
                file.close
                file.unlink
              end

            # attachment size validation (supports less_than and greater_than)
            elsif method == :size && options.is_a?(Hash)
              content_type_rule = v.find { |val| val.is_a?(Hash) && val[:content_type] }
              content_type = content_type_rule ? content_type_rule[:content_type][:allowed].first : 'application/pdf'
              file_extension = CONTENT_TYPE_EXTENSIONS[content_type] || '.bin'

              if options[:less_than]
                size_limit = options[:less_than]
                message = options[:less_than_message] || options[:message] || "must be less than #{size_limit / 1.megabyte}MB"
                it "validates size of #{k} to be less than #{size_limit / 1.megabyte}MB" do
                  file = Tempfile.new([ 'large', file_extension ])
                  file.write('a' * (size_limit + 1)) # Oversized file
                  file.rewind
                  subject.send(k).attach(io: file, filename: "large#{file_extension}", content_type: content_type)
                  subject.valid?
                  expect(subject.errors[k]).to include(message)
                ensure
                  file.close
                  file.unlink
                end
              end

              if options[:greater_than]
                size_minimum = options[:greater_than]
                unit = size_minimum < 1.megabyte ? :kilobyte : :megabyte
                divisor = unit == :kilobyte ? 1.kilobyte : 1.megabyte
                message = options[:greater_than_message] || options[:message] || "must be greater than #{size_minimum / divisor}#{unit == :kilobyte ? 'KB' : 'MB'}"
                it "validates size of #{k} to be greater than #{size_minimum / divisor}#{unit == :kilobyte ? 'KB' : 'MB'}" do
                  file = Tempfile.new([ 'small', file_extension ])
                  file.write('a' * (size_minimum - 1)) # Undersized file
                  file.rewind
                  subject.send(k).attach(io: file, filename: "small#{file_extension}", content_type: content_type)
                  expect(subject.send(k)).to be_attached
                  subject.valid?
                  expect(subject.errors[k]).to include(message)
                ensure
                  file.close
                  file.unlink
                end
              end
            # Other validations with options
            else
              it do
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
              end
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
