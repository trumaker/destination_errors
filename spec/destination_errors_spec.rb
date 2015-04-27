RSpec.describe DestinationErrors do
  MyClass = Class.new do
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
  let(:instance) { MyClass.new }
  context "works" do
    it("is defined") { expect { MyClass }.to_not raise_error }
    it("with intialize") { expect { instance }.to_not raise_error }
  end
  context "class_attributes" do
    before { MyClass.error_surfaces = [nil] }
    it("reads and writes error_surfaces") {
      expect(MyClass.error_surfaces).to eq [nil]
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
        let(:surface1) { MyClass.new("asdf", "burgle") }
        let(:surface2) { MyClass.new("qwer", "beagle") }
        let(:instance) { MyClass.new(surface1, surface2) }
        before {
          MyClass.error_surfaces = [nil, :surface1, :surface2]
          instance.surface_errors_on = :surface1
          instance.errors.add(:base, "ON INSTANCE")
          instance.errors.add(:surface1, "ON :surface1")
          instance.errors.add(:surface2, "ON :surface2")
          instance.surface1.errors.add(:base, "ON SURFACE 1 BASE")
          instance.surface2.errors.add(:base, "ON SURFACE 2 BASE")
          instance.surface1.errors.add(:surface1, "ON SURFACE 1 :surface1")
          instance.surface1.errors.add(:surface2, "ON SURFACE 1 :surface2")
          instance.surface2.errors.add(:surface1, "ON SURFACE 2 :surface1")
          instance.surface2.errors.add(:surface2, "ON SURFACE 2 :surface2")
          instance.surface2.errors.add(:surface2, "ON SURFACE 2 :surface2")
          instance.surface2.errors.add(:surface2, "ON SURFACE 2 :surface2")
          instance.surface2.errors.add(:surface2, "ON SURFACE 2 :surface2")
          instance.surface2.errors.add(:surface2, "ON SURFACE 2 :surface2")
        }
        it("overrides default") { expect(instance.send(:error_destination)).to eq surface1  }
        it("is not clean") { expect(instance.error_surfaces_clean?).to eq false }
        context "moving errors" do
          before { instance.finalize }
          it("retain errors on non destination") {
            expect(instance.errors.full_messages).to eq ["ON INSTANCE", "surface1 ON :surface1", "surface2 ON :surface2"]
          }
          it("doesn't alter errors on non destination") {
            expect(instance.errors[:surface1]).to eq ["ON :surface1"]
          }
          it("moves errors to destination") {
            expect(instance.surface1.errors.full_messages.sort).to eq ["ON INSTANCE", "ON SURFACE 1 BASE", "ON SURFACE 2 BASE", "surface1 ON :surface1", "surface1 ON SURFACE 1 :surface1", "surface1 ON SURFACE 2 :surface1", "surface2 ON :surface2", "surface2 ON SURFACE 1 :surface2", "surface2 ON SURFACE 2 :surface2"].sort
          }
          it("moves :base errors to destination at :base") {
            expect(instance.surface1.errors[:base].sort).to eq ["ON INSTANCE", "ON SURFACE 1 BASE", "ON SURFACE 2 BASE"].sort
          }
          it("moves attribute errors to destination attribute") {
            expect(instance.surface1.errors[:surface1].sort).to eq ["ON :surface1", "ON SURFACE 1 :surface1", "ON SURFACE 2 :surface1"].sort
          }
          it("moves errors uniquely") {
            expect(instance.surface2.errors[:surface2].sort).to eq ["ON SURFACE 2 :surface2", "ON SURFACE 2 :surface2", "ON SURFACE 2 :surface2", "ON SURFACE 2 :surface2", "ON SURFACE 2 :surface2"].sort
            expect(instance.surface1.errors[:surface2].sort).to eq ["ON :surface2", "ON SURFACE 1 :surface2", "ON SURFACE 2 :surface2"].sort
          }
        end
      end
    end
  end

end
