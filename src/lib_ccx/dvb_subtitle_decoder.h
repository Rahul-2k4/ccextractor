/*
 * DVB subtitle decoding
 * Copyright (c) 2014 Anshul
 * License: LGPL
 *
 * This file is part of CCEXtractor
 * You should have received a copy of the GNU Lesser General Public
 * License along with CCExtractor; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 *
 */
/**
 * @file dvbsub.c
 */

#ifndef DVBSUBDEC_H
#define DVBSUBDEC_H

#define MAX_LANGUAGE_PER_DESC 5

#include "lib_ccx.h"
#ifdef __cplusplus
extern "C"
{
#endif

	// --- STRUCT DEFINITIONS MOVED FROM .C ---

	typedef struct DVBSubCLUT
	{
		int id;
		int version;

		uint32_t clut4[4];
		uint32_t clut16[16];
		uint32_t clut256[256];
		uint8_t ilut4[4];
		uint8_t ilut16[16];
		uint8_t ilut256[256];

		struct DVBSubCLUT *next;
	} DVBSubCLUT;

	typedef struct DVBSubObjectDisplay
	{
		int object_id;
		int region_id;

		int x_pos;
		int y_pos;

		int fgcolor;
		int bgcolor;

		struct DVBSubObjectDisplay *region_list_next;
		struct DVBSubObjectDisplay *object_list_next;
	} DVBSubObjectDisplay;

	typedef struct DVBSubObject
	{
		int id;
		int version;

		int type;

		DVBSubObjectDisplay *display_list;

		struct DVBSubObject *next;
	} DVBSubObject;

	typedef struct DVBSubRegionDisplay
	{
		int region_id;

		int x_pos;
		int y_pos;

		struct DVBSubRegionDisplay *next;
	} DVBSubRegionDisplay;

	typedef struct DVBSubRegion
	{
		int id;
		int version;

		int width;
		int height;
		int depth;

		int clut;
		int bgcolor;

		uint8_t *pbuf;
		int buf_size;
		int dirty;

		DVBSubObjectDisplay *display_list;

		struct DVBSubRegion *next;
	} DVBSubRegion;

	typedef struct DVBSubDisplayDefinition
	{
		int version;

		int x;
		int y;
		int width;
		int height;
	} DVBSubDisplayDefinition;

	// --- CONFIG & CONTEXT ---

	struct dvb_config
	{
		unsigned char n_language;
		unsigned int lang_index[MAX_LANGUAGE_PER_DESC];
		/* subtitle type */
		unsigned char sub_type[MAX_LANGUAGE_PER_DESC];
		/* composition page id */
		unsigned short composition_id[MAX_LANGUAGE_PER_DESC];
		/* ancillary_page_id */
		unsigned short ancillary_id[MAX_LANGUAGE_PER_DESC];
	};

	// ISOLATION CONTEXT (Replaces globals)
	struct ccx_decoders_dvb_context
	{
		// Timing & Output
		struct ccx_common_timing_ctx *timing; // Points to pipeline's timing
		struct encoder_ctx *encoder;          // Points to pipeline's output encoder

		// DVB State
		int composition_id;
		int ancillary_id;
		int version;
		LLONG time_out; // Changed to LLONG to match DVBSubContext usage
		int compute_ids; // Flag to compute IDs if missing
		
		// Linked lists for objects/regions/cluts
		DVBSubRegionDisplay *display_list;
		DVBSubCLUT *clut_list;
		DVBSubRegion *region_list;
		DVBSubObject *object_list;
		DVBSubDisplayDefinition *display_definition;
		
		DVBSubCLUT default_clut; 
		
	#ifdef ENABLE_OCR
		void *ocr_ctx; // OCR Context
	#endif

		// Helpers for ID management
		int prev_ancillary_id;
		int prev_composition_id;
	};

	// --- FUNCTION PROTOTYPES ---

	/**
	 * Initialize a DVB subtitle decoder instance
	 */
	void *dvb_init_decoder(struct ccx_common_timing_ctx *timing, struct encoder_ctx *encoder);

	/**
	 * Free a DVB subtitle decoder instance
	 */
	void dvb_free_decoder(void *ctx);

	/**
	 * Decode a DVB subtitle packet
	 */
	int dvb_decode(void *ctx, struct lib_cc_decode *dec_ctx, const unsigned char *buf, int buf_size, struct cc_subtitle *sub);

	/**
	 * Parse DVB description from PMT
	 */
	int parse_dvb_description(struct dvb_config *cfg, unsigned char *data,
				  unsigned int len);

	// Legacy kept for compatibility (may be removed or updated)
	void dvbsub_set_write(void *dvb_ctx, struct ccx_s_write *out);

#ifdef __cplusplus
}
#endif
#endif