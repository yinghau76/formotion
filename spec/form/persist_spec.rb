describe "Form Persisting" do

  it "works" do
    key = "test_#{rand(255)}"
    App::Persistence["FORMOTION_#{key}"] = nil
    App::Persistence["FORMOTION_#{key}_ORIGINAL"] = nil
    f = Formotion::Form.persist({
      persist_as: key,
      sections: [
        rows: [ {
            key: "first",
            type: "string",
            value: "initial value"
          }
        ]
      ]
    })

    r = f.sections[0].rows[0]
    r.value = "new value"

    saved = f.send(:load_state)
    saved["first"] == r.value

    f.reset
    r.value.should == "initial value"
  end

  it "works with subforms" do
    key = "test_#{rand(255)}"
    App::Persistence["FORMOTION_#{key}"] = nil
    App::Persistence["FORMOTION_#{key}_ORIGINAL"] = nil
    hash = {
      persist_as: key,
      sections: [
        rows: [ {
            key: :subform,
            type: :subform,
            title: "Subform",
            subform: {
              title: "New Page",
              sections: [
                rows: [{
                  key: "second",
                  type: "string",
                  value: "initial value"
                }]
              ]
            }
          }
        ]
      ]
    }
    f = Formotion::Form.persist(hash)
    f.to_hash.should == hash

    r = f.sections[0].rows[0].subform.to_form.sections[0].rows[0]
    r.value = "new value"

    saved = f.send(:load_state)
    saved[:subform]["second"].should == r.value

    f.reset
    r.value.should == "initial value"
  end

  it "works with templates" do
    key = "test_#{rand(255)}"
    App::Persistence["FORMOTION_#{key}"] = nil
    App::Persistence["FORMOTION_#{key}_ORIGINAL"] = nil
    hash = {
      persist_as: key,
      sections: [
        rows: [{
          title: "Add nickname",
          key: :nicknames,
          type: :template,
          value: ['Nici', 'Sam'],
          template: {
            title: 'Nickname',
            type: :string,
            placeholder: 'Enter here',
            indented: true,
            deletable: true
          }
        }]
      ]
    }
    f = Formotion::Form.persist(hash)
    f.render.should == { :nicknames => ['Nici', 'Sam'] }

    r = f.sections[0].rows[0]
    r.value = "Sandra"

    saved = f.send(:load_state)
    saved[:nicknames].should == ["Sandra", "Sam"]

    f.reset
    r.value.should == "Nici"
  end

  it "can restore the value of keyed section" do
      key = "test_#{rand(255)}"
      App::Persistence["FORMOTION_#{key}"] = nil
      App::Persistence["FORMOTION_#{key}_ORIGINAL"] = nil
      hash = {
        persist_as: key,
        sections: [
          key: :gender,
          select_one: true,
          rows: [ {
              title: 'Male',
              key: :male,
              type: :check
            }, {
              title: 'Female',
              key: :female,
              type: :check
            }, {
              title: 'Unsaid',
              key: :unsaid,
              type: :check
            }
          ]
        ]
      }
      # select 'Female'
      f = Formotion::Form.persist(hash)
      f.sections[0].rows[1].value = true

      saved = f.send(:load_state)
      # the saved value should be 'Female'
      saved[:gender].should == 'female'

      # Create another form with saved data
      another = Formotion::Form.persist(hash)
      # 'Female' should be selected
      another.sections[0].rows[1].value.should == true
    end
end