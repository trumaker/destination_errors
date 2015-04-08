RSpec.describe DestinationErrors do
  let(:klass) { Class.new do
      attr_accessor :surface1, :surface2
      include DestinationErrors
      def initialize(surface1 = nil, surface2 = nil)
        @surface1 = surface1
        @surface2 = surface2
      end
      def finalize
        move_all_errors_to_destination
      end
    end
  }
  let(:instance) { klass.new }
  context "works" do
    it("is defined") { expect { klass }.to_not raise_error }
    it("with intialize") { expect { instance }.to_not raise_error }
  end
  context "class_attributes" do
    before { klass.error_surfaces = [nil] }
    it("reads and writes error_surfaces") {
      expect(klass.error_surfaces).to eq [nil]
    }
  end
  context "attr_readers" do
    it("has errors") { expect(instance.errors).to be_a ActiveModel::Errors }
  end
  context "attr_accessors" do
    it("reads and writes surface_errors_on") {
      expect(instance.surface_errors_on).to be_nil
      instance.surface_errors_on = [:thing]
      expect(instance.surface_errors_on).to eq [:thing]
    }
  end
  describe "instance methods" do
    context "errors" do
      it("add") {
        expect { instance.errors.add(:base, "ERROR") }.to_not raise_error
        expect(instance.errors.full_messages).to eq ["ERROR"]
      }
    end
    context "error_destination" do
      it("defaults to self") { expect(instance.send(:error_destination)).to eq instance }
      context "custom" do
        let(:surface1) { klass.new }
        let(:surface2) { klass.new }
        let(:instance) { klass.new(surface1, surface2) }
        before {
          klass.error_surfaces = [nil, :surface1, :surface2]
          instance.surface_errors_on = :surface1
          instance.errors.add(:base, "ON INSTANCE")
          instance.surface1.errors.add(:base, "ON SURFACE 1")
          instance.surface2.errors.add(:base, "ON SURFACE 2")
        }
        it("overrides default") { expect(instance.send(:error_destination)).to eq surface1  }
        it("is not clean") { expect(instance.error_surfaces_clean?).to eq false }
        it("moves errors to destination") {
          instance.finalize
          expect(instance.errors.full_messages).to eq ["ON INSTANCE"]
          expect(instance.surface1.errors.full_messages.sort).to eq ["ON INSTANCE", "ON SURFACE 1", "ON SURFACE 2"].sort
        }
      end
    end
  end

end
