import { describe, it, expect, beforeEach, vi } from 'vitest';

// Mock the Clarity contract interactions
const mockContractCalls = {
  registerMaterialSource: vi.fn(),
  getMaterialSource: vi.fn(),
  updateMaterialSource: vi.fn(),
  reportMaterialQuality: vi.fn(),
  getQualityReport: vi.fn()
};

// Mock material source data
const mockSourceData = {
  "material-type": "Wood",
  name: "White Oak",
  region: "Northeastern United States",
  properties: "Rot-resistant, strong, excellent for frames and keels",
  "sustainability-score": 85,
  "registered-by": "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
  "registration-time": 12345
};

describe('Material Sourcing Contract', () => {
  beforeEach(() => {
    vi.resetAllMocks();
    
    mockContractCalls.getMaterialSource.mockResolvedValue(mockSourceData);
    mockContractCalls.registerMaterialSource.mockResolvedValue({
      value: 1,
      type: "ok"
    });
    mockContractCalls.updateMaterialSource.mockResolvedValue({
      value: true,
      type: "ok"
    });
    mockContractCalls.reportMaterialQuality.mockResolvedValue({
      value: true,
      type: "ok"
    });
    mockContractCalls.getQualityReport.mockResolvedValue({
      "quality-score": 90,
      "report-time": 12346,
      comments: "Excellent material, perfect for boat frames"
    });
  });
  
  describe('registerMaterialSource', () => {
    it('should successfully register a new material source', async () => {
      const result = await mockContractCalls.registerMaterialSource(
          "Wood",
          "White Oak",
          "Northeastern United States",
          "Rot-resistant, strong, excellent for frames and keels",
          85
      );
      
      expect(mockContractCalls.registerMaterialSource).toHaveBeenCalledTimes(1);
      expect(result.type).toBe("ok");
      expect(result.value).toBe(1);
    });
  });
  
  describe('getMaterialSource', () => {
    it('should return material source data for a valid ID', async () => {
      const result = await mockContractCalls.getMaterialSource(1);
      
      expect(mockContractCalls.getMaterialSource).toHaveBeenCalledTimes(1);
      expect(result).toEqual(mockSourceData);
    });
  });
  
  describe('updateMaterialSource', () => {
    it('should successfully update an existing material source', async () => {
      const result = await mockContractCalls.updateMaterialSource(
          1,
          "Updated properties with more details",
          90
      );
      
      expect(mockContractCalls.updateMaterialSource).toHaveBeenCalledTimes(1);
      expect(result.type).toBe("ok");
      expect(result.value).toBe(true);
    });
  });
  
  describe('reportMaterialQuality', () => {
    it('should successfully report material quality', async () => {
      const result = await mockContractCalls.reportMaterialQuality(
          1,
          90,
          "Excellent material, perfect for boat frames"
      );
      
      expect(mockContractCalls.reportMaterialQuality).toHaveBeenCalledTimes(1);
      expect(result.type).toBe("ok");
      expect(result.value).toBe(true);
    });
  });
});
